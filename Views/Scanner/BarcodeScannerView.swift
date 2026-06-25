// MARK: - BarcodeScannerView.swift
// NutriAI Pro — Scanner coduri de bare via AVFoundation
// Faza 3 | iOS 17+ | iPhone 15 Pro Max optimizat

import SwiftUI
import AVFoundation

// MARK: - BarcodeScannerView (SwiftUI Wrapper)
/// View SwiftUI care învelește controlerul UIKit de scanare AVFoundation
struct BarcodeScannerView: UIViewControllerRepresentable {

    // MARK: - Callbacks
    var onCodDetectat: (String) -> Void
    var onEroare: (ScannerError) -> Void
    var onInchide: () -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onCodDetectat = onCodDetectat
        vc.onEroare = onEroare
        vc.onInchide = onInchide
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject {}
}

// MARK: - ScannerViewController
/// UIViewController cu AVCaptureSession complet pentru scanare barcode
class ScannerViewController: UIViewController {

    // MARK: - Callbacks
    var onCodDetectat: ((String) -> Void)?
    var onEroare: ((ScannerError) -> Void)?
    var onInchide: (() -> Void)?

    // MARK: - AVFoundation
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var esteScaning: Bool = false

    // MARK: - UI Overlay
    private var overlayHostingController: UIHostingController<ScannerOverlayView>?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        verificaPermisiuneCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumaScaning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        opreScaningul()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    // MARK: - Permisiune Cameră
    private func verificaPermisiuneCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureazaScaner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] acordata in
                DispatchQueue.main.async {
                    if acordata {
                        self?.configureazaScaner()
                    } else {
                        self?.onEroare?(.permisiuneDenied)
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.onEroare?(.permisiuneDenied)
            }
        @unknown default:
            break
        }
    }

    // MARK: - Configurare AVCaptureSession
    private func configureazaScaner() {
        let session = AVCaptureSession()
        self.captureSession = session

        // Camera posterioară (principală pe iPhone 15 Pro Max)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            DispatchQueue.main.async { self.onEroare?(.camerăIndisponibilă) }
            return
        }

        // Configurare focus și expunere automată
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        } catch {
            // Continuăm fără configurare specială
        }

        // Input
        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            DispatchQueue.main.async { self.onEroare?(.camerăIndisponibilă) }
            return
        }
        session.addInput(input)

        // Output Metadata (barcode)
        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)

        // Tipuri suportate:
        // .ean8  → EAN-8 (8 cifre, Europa)
        // .ean13 → EAN-13 + UPC-A (vine ca EAN-13 în AVFoundation)
        // .upce  → UPC-E (format comprimat)
        // .qr    → QR Code (bonus)
        // .code128 → coduri de bare generice
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .qr, .code128]

        // Preview Layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        // Adaugă overlay SwiftUI deasupra preview-ului
        adaugaOverlay()

        // Start session pe background thread (blocking)
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        esteScaning = true
    }

    // MARK: - Overlay UI
    private func adaugaOverlay() {
        let overlayView = ScannerOverlayView(
            onLanterna: { [weak self] in self?.toggleLanterna() },
            onInchide: { [weak self] in self?.onInchide?() }
        )

        let hosting = UIHostingController(rootView: overlayView)
        hosting.view.backgroundColor = .clear

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.didMove(toParent: self)
        overlayHostingController = hosting
    }

    // MARK: - Control Sesiune
    func resumaScaning() {
        guard let session = captureSession, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        esteScaning = true
    }

    func opreScaningul() {
        guard let session = captureSession, session.isRunning else { return }
        session.stopRunning()
        esteScaning = false
    }

    // MARK: - Lanternă
    func toggleLanterna() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            device.unlockForConfiguration()
        } catch {}
    }

    // MARK: - Animație Succes
    private func animatieSucces() {
        let flash = UIView(frame: view.bounds)
        flash.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.3)
        flash.alpha = 0
        view.addSubview(flash)
        UIView.animate(withDuration: 0.15, animations: {
            flash.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.1) {
                flash.alpha = 0
            } completion: { _ in
                flash.removeFromSuperview()
            }
        }

        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard esteScaning,
              let obiect = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let codDetectat = obiect.stringValue,
              !codDetectat.isEmpty else { return }

        // Oprire scanare pentru a evita detectări multiple
        esteScaning = false
        opreScaningul()

        // Animație flash verde
        animatieSucces()

        // Callback după animație
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.onCodDetectat?(codDetectat)
        }
    }
}
