// MARK: - FoodDatabaseService.swift
// NutriAI Pro — Serviciu fetch date nutriționale din Open Food Facts
// Faza 3: Barcode Scanner
// API: https://world.openfoodfacts.org/api/v0/product/{barcode}.json

import Foundation

// MARK: - FoodDatabaseService
/// Serviciu async thread-safe pentru căutarea produselor după barcode
actor FoodDatabaseService {

    // MARK: - Singleton
    static let shared = FoodDatabaseService()

    // MARK: - Configurare
    /// Pe Simulator sau fără internet → mod mock
    private let modMock: Bool = false

    /// API v2 cu filtrare câmpuri pentru payload mic (~5x mai rapid)
    private let baseURL = "https://world.openfoodfacts.org/api/v2/product"
    private let campuriFetch = "product_name,product_name_ro,product_name_en,brands,serving_size,serving_quantity,image_front_url,image_url,nutriments"
    private let timeoutInterval: TimeInterval = 10.0

    private var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 20.0
        // User-Agent recomandat de Open Food Facts pentru identificarea app-urilor
        config.httpAdditionalHeaders = [
            "User-Agent": "NutriAIPro/1.0 (iOS 26; contact@nutriaipro.ro)"
        ]
        return URLSession(configuration: config)
    }()

    // MARK: - Cache simplu în memorie
    private var cache: [String: ScannedProduct] = [:]

    // MARK: - Căutare Produs după Barcode
    /// Returnează produsul identificat sau aruncă `ScannerError`
    func cautaProdus(barcode: String) async throws -> ScannedProduct {

        // 1. Cache hit
        if let produsCache = cache[barcode] {
            return produsCache
        }

        // 2. Mock mode (Simulator / offline)
        if modMock {
            return try await cautaMock(barcode: barcode)
        }

        // 3. Fetch real din Open Food Facts
        return try await fetchOpenFoodFacts(barcode: barcode)
    }

    // MARK: - Fetch Open Food Facts API
    private func fetchOpenFoodFacts(barcode: String) async throws -> ScannedProduct {
        guard let url = URL(string: "\(baseURL)/\(barcode).json?fields=\(campuriFetch)") else {
            throw ScannerError.dateInvalide
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError {
            if error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
                // Fallback la mock dacă nu există internet
                return try await cautaMock(barcode: barcode)
            }
            throw ScannerError.rețeaIndisponibilă
        }

        // Verificare HTTP status
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw ScannerError.rețeaIndisponibilă
        }

        // Decodificare JSON
        let decoder = JSONDecoder()
        let apiResponse: OFFApiResponse
        do {
            apiResponse = try decoder.decode(OFFApiResponse.self, from: data)
        } catch {
            throw ScannerError.dateInvalide
        }

        // Verificare dacă produsul există
        guard apiResponse.status == 1, let product = apiResponse.product else {
            throw ScannerError.produsFăsGăsit(barcode)
        }

        // Construire ScannedProduct
        let produs = construiesteProdus(din: product, barcode: barcode)

        // Validare date minime
        guard produs.areDate else {
            throw ScannerError.dateInvalide
        }

        // Salvare în cache
        cache[barcode] = produs
        return produs
    }

    // MARK: - Construire ScannedProduct din OFFProduct
    private func construiesteProdus(din product: OFFProduct, barcode: String) -> ScannedProduct {
        let nutriments = product.nutriments

        return ScannedProduct(
            barcode: barcode,
            numeProdus: product.numeCalculat,
            brand: product.brands?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? "",
            urlImagine: product.imageFrontUrl ?? product.imageUrl,
            kcalPer100g: nutriments?.kcal ?? 0,
            proteinePer100g: nutriments?.proteine100g ?? 0,
            carboPer100g: nutriments?.carbo100g ?? 0,
            grasimiPer100g: nutriments?.grasimi100g ?? 0,
            fibrePer100g: nutriments?.fibre100g ?? 0,
            zaharPer100g: nutriments?.zahar100g ?? 0,
            marimePorţie: product.servingSize,
            cantitateGramePorţie: product.servingQuantity
        )
    }

    // MARK: - Mock (Simulator / offline)
    private func cautaMock(barcode: String) async throws -> ScannedProduct {
        // Simulăm latența rețelei pentru UX realist
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8s

        guard let produsMock = ScannedProduct.mockuri[barcode] else {
            throw ScannerError.produsFăsGăsit(barcode)
        }

        cache[barcode] = produsMock
        return produsMock
    }

    // MARK: - Căutare Manuală după Nume (bonus)
    /// Caută produse în baza de date Open Food Facts după text
    func cautaDupaText(query: String, tara: String = "ro") async throws -> [ScannedProduct] {
        guard !modMock else {
            // Mock: returnează primele 3 produse demo
            return Array(ScannedProduct.mockuri.values.prefix(3))
        }

        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(encodedQuery)&search_simple=1&action=process&json=1&page_size=10&lc=ro") else {
            throw ScannerError.dateInvalide
        }

        let (data, _) = try await session.data(from: url)

        // Parsare simplificată pentru search results
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let products = json["products"] as? [[String: Any]] {
            return products.compactMap { productDict -> ScannedProduct? in
                guard let name = productDict["product_name"] as? String, !name.isEmpty,
                      let nutriments = productDict["nutriments"] as? [String: Any],
                      let kcal = nutriments["energy-kcal_100g"] as? Double else {
                    return nil
                }

                return ScannedProduct(
                    barcode: productDict["code"] as? String ?? "",
                    numeProdus: name,
                    brand: productDict["brands"] as? String ?? "",
                    urlImagine: productDict["image_url"] as? String,
                    kcalPer100g: kcal,
                    proteinePer100g: nutriments["proteins_100g"] as? Double ?? 0,
                    carboPer100g: nutriments["carbohydrates_100g"] as? Double ?? 0,
                    grasimiPer100g: nutriments["fat_100g"] as? Double ?? 0,
                    fibrePer100g: nutriments["fiber_100g"] as? Double ?? 0,
                    zaharPer100g: nutriments["sugars_100g"] as? Double ?? 0,
                    marimePorţie: productDict["serving_size"] as? String,
                    cantitateGramePorţie: productDict["serving_quantity"] as? Double
                )
            }
        }
        return []
    }

    // MARK: - Curăță Cache
    func curataCache() {
        cache.removeAll()
    }
}
