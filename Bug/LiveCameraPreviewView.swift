//
//  LiveCameraPreviewView.swift
//  Bug
//
//  Bug ID — Live camera preview using AVFoundation
//

import SwiftUI
import AVFoundation

struct LiveCameraPreviewView: UIViewControllerRepresentable {
    let session: AVCaptureSession

    func makeUIViewController(context: Context) -> CameraPreviewViewController {
        let vc = CameraPreviewViewController()
        vc.session = session
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraPreviewViewController, context: Context) {
        uiViewController.session = session
    }
}

final class CameraPreviewViewController: UIViewController {
    var session: AVCaptureSession? {
        didSet { 
            previewLayer.session = session
            // Schedule orientation update with a slight delay to ensure connection is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateVideoOrientation()
                self?.updateZoomLimits()
            }
        }
    }

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    // Zoom properties
    private var minZoomFactor: CGFloat = 1.0
    private var maxZoomFactor: CGFloat = 10.0
    private var currentZoomFactor: CGFloat = 1.0
    private var beginZoomScale: CGFloat = 1.0
    
    // Store reference to camera device for zoom control
    private var cameraDevice: AVCaptureDevice? {
        return (session?.inputs.first as? AVCaptureDeviceInput)?.device
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[Camera Preview] viewDidAppear called")
        // Update orientation and zoom with multiple retries to ensure connection is ready
        updateVideoOrientation()
        updateZoomLimits()
        
        // Retry after a delay to ensure everything is initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.updateVideoOrientation()
            self?.updateZoomLimits()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateVideoOrientation()
            self?.updateZoomLimits()
        }
    }
    
    private func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    private func updateZoomLimits() {
        guard let device = cameraDevice else {
            print("[Camera Preview] No camera device available for zoom limits")
            return
        }
        
        minZoomFactor = device.minAvailableVideoZoomFactor
        maxZoomFactor = min(device.maxAvailableVideoZoomFactor, 10.0) // Cap at 10x for usability
        currentZoomFactor = device.videoZoomFactor
        print("[Camera Preview] Zoom limits updated: min=\(minZoomFactor), max=\(maxZoomFactor), current=\(currentZoomFactor)")
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let device = cameraDevice else {
            print("[Camera] No camera device available for zoom")
            return
        }
        
        switch gesture.state {
        case .began:
            beginZoomScale = currentZoomFactor
            
        case .changed:
            let scale = gesture.scale
            let newZoomFactor = beginZoomScale * scale
            let clampedZoomFactor = min(max(newZoomFactor, minZoomFactor), maxZoomFactor)
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = clampedZoomFactor
                device.unlockForConfiguration()
                currentZoomFactor = clampedZoomFactor
            } catch {
                print("[Camera] Error adjusting zoom: \(error.localizedDescription)")
            }
            
        case .ended, .cancelled:
            // Zoom level is maintained at current position
            break
            
        default:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        updateVideoOrientation()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.updateVideoOrientation()
        }
    }

    private func updateVideoOrientation() {
        guard let connection = previewLayer.connection else {
            print("[Camera Preview] No connection available yet")
            return
        }
        
        // Get the current interface orientation
        let interfaceOrientation: UIInterfaceOrientation
        if let windowScene = view.window?.windowScene {
            if #available(iOS 26.0, *) {
                interfaceOrientation = windowScene.effectiveGeometry.interfaceOrientation
            } else {
                interfaceOrientation = windowScene.interfaceOrientation
            }
        } else {
            print("[Camera Preview] No window scene available, using portrait")
            // Fallback to portrait if we can't get window scene
            interfaceOrientation = .portrait
        }
        
        print("[Camera Preview] Interface orientation: \(interfaceOrientation.rawValue) (\(interfaceOrientation))")
        
        // Convert UIInterfaceOrientation to rotation angle (in degrees)
        // These angles represent how much the video should be rotated clockwise
        let rotationAngle: CGFloat
        switch interfaceOrientation {
        case .portrait:
            rotationAngle = 90
        case .portraitUpsideDown:
            rotationAngle = 270
        case .landscapeLeft:
            rotationAngle = 180    // Match capture service
        case .landscapeRight:
            rotationAngle = 0      // Match capture service
        case .unknown:
            rotationAngle = 90
        @unknown default:
            rotationAngle = 90
        }
        
        print("[Camera Preview] Setting rotation angle to: \(rotationAngle)")
        
        if connection.isVideoRotationAngleSupported(rotationAngle) {
            connection.videoRotationAngle = rotationAngle
            print("[Camera Preview] Successfully set rotation angle to \(rotationAngle)")
        } else {
            print("[Camera Preview] Rotation angle \(rotationAngle) not supported!")
        }
    }
}
