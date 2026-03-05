//
//  CameraCaptureService.swift
//  Bug
//
//  Bug ID — Manages AVCaptureSession and photo capture
//

import AVFoundation
import Combine
import UIKit

@MainActor
final class CameraCaptureService: ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let photoDelegate: PhotoCaptureDelegate

    @Published var isAuthorized = false
    @Published var setupError: String?

    init() {
        photoDelegate = PhotoCaptureDelegate()
    }

    func configure() async {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted {
                isAuthorized = false
                setupError = "Camera access denied"
                return
            }
        }
        isAuthorized = true

        // Run session configuration and start on background thread to avoid blocking UI
        await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let session = await self.session
            let photoOutput = await self.photoOutput
            
            session.beginConfiguration()
            session.sessionPreset = .photo

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                session.commitConfiguration()
                await MainActor.run {
                    self.setupError = "Camera not available"
                }
                return
            }

            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }

            session.commitConfiguration()
            session.startRunning()
        }.value
    }

    func stopSession() {
        Task.detached(priority: .utility) { [weak self] in
            guard let self = self else { return }
            let session = await self.session
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }

    func capturePhoto() async -> UIImage? {
        // Get the current interface orientation
        let interfaceOrientation: UIInterfaceOrientation
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            
            if #available(iOS 26.0, *) {
                interfaceOrientation = windowScene.effectiveGeometry.interfaceOrientation
            } else {
                interfaceOrientation = windowScene.interfaceOrientation
            }
        } else {
            // Fallback to device orientation if window scene is unavailable
            let deviceOrientation = UIDevice.current.orientation
            switch deviceOrientation {
            case .portrait:
                interfaceOrientation = .portrait
            case .portraitUpsideDown:
                interfaceOrientation = .portraitUpsideDown
            case .landscapeLeft:
                // Device and interface orientations are opposite for landscape
                interfaceOrientation = .landscapeRight
            case .landscapeRight:
                // Device and interface orientations are opposite for landscape
                interfaceOrientation = .landscapeLeft
            default:
                interfaceOrientation = .portrait
            }
        }
        
        print("[Camera Capture] Interface orientation: \(interfaceOrientation.rawValue) (\(interfaceOrientation))")
        
        // Convert UIInterfaceOrientation to rotation angle (in degrees)
        // These angles represent how much the video should be rotated clockwise
        let rotationAngle: CGFloat
        switch interfaceOrientation {
        case .portrait:
            rotationAngle = 90
        case .portraitUpsideDown:
            rotationAngle = 270
        case .landscapeLeft:
            rotationAngle = 180
        case .landscapeRight:
            rotationAngle = 0
        case .unknown:
            rotationAngle = 90
        @unknown default:
            rotationAngle = 90
        }
        
        print("[Camera Capture] Setting rotation angle to: \(rotationAngle)")
        
        if let connection = photoOutput.connection(with: .video),
           connection.isVideoRotationAngleSupported(rotationAngle) {
            connection.videoRotationAngle = rotationAngle
        }
        
        return await photoDelegate.capture(photoOutput: photoOutput)
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private nonisolated(unsafe) var _continuation: CheckedContinuation<UIImage?, Never>?

    func capture(photoOutput: AVCapturePhotoOutput) async -> UIImage? {
        await withCheckedContinuation { cont in
            lock.lock()
            _continuation = cont
            lock.unlock()
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }

    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        lock.lock()
        let cont = _continuation
        _continuation = nil
        lock.unlock()
        if error != nil {
            cont?.resume(returning: nil)
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            cont?.resume(returning: nil)
            return
        }
        cont?.resume(returning: image)
    }
}
