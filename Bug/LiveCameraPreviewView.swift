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
        didSet { previewLayer.session = session }
    }

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
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
        let rotationAngle: CGFloat
        switch UIDevice.current.orientation {
        case .portraitUpsideDown: rotationAngle = 270
        case .landscapeLeft: rotationAngle = 0
        case .landscapeRight: rotationAngle = 180
        default: rotationAngle = 90
        }
        guard let connection = previewLayer.connection,
              connection.isVideoRotationAngleSupported(rotationAngle) else { return }
        connection.videoRotationAngle = rotationAngle
    }
}
