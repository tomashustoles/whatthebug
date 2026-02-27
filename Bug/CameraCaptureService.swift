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

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            setupError = "Camera not available"
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
    }

    func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    func capturePhoto() async -> UIImage? {
        let rotationAngle: CGFloat
        switch UIDevice.current.orientation {
        case .portraitUpsideDown: rotationAngle = 270
        case .landscapeLeft: rotationAngle = 0
        case .landscapeRight: rotationAngle = 180
        default: rotationAngle = 90
        }
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
