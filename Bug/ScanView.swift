//
//  ScanView.swift
//  Bug
//
//  Bug ID — Camera scan screen
//

import SwiftUI

struct ScanView: View {
    var onInsectCaptured: (CapturedInsect) -> Void = { _ in }
    
    @State private var viewModel = BugAnalysisViewModel()
    @State private var selectedImage: UIImage?
    @State private var showAnalysisSheet = false
    @State private var pickerSourceType: CameraPickerView.SourceType?
    @StateObject private var cameraService = CameraCaptureService()
    @State private var isCapturing = false

    var body: some View {
        ZStack {
            if cameraService.isAuthorized {
                LiveCameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Photograph Insect")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                    .padding(.top, 60)
                    .padding(.horizontal)

                Spacer()

                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height) * 0.85
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.white, lineWidth: 2)
                        .frame(width: size, height: size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 340)
                .padding(.horizontal, 24)

                Spacer()

                GlassEffectContainer(spacing: 24) {
                    HStack(alignment: .bottom, spacing: 24) {
                        Button {
                            pickerSourceType = .photoLibrary
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 22))
                                .frame(width: 56, height: 56)
                                .glassEffect(.regular.interactive())
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { await capturePhoto() }
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(.white.opacity(0.5), lineWidth: 3)
                                    .frame(width: 76, height: 76)
                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                        }
                        .buttonStyle(.plain)
                        .disabled(isCapturing)
                        .opacity(isCapturing ? 0.6 : 1)

                        Color.clear
                            .frame(width: 56, height: 56)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 120)
                }
            }
        }
        .task {
            await cameraService.configure()
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .fullScreenCover(item: $pickerSourceType) { sourceType in
            CameraPickerView(
                sourceType: sourceType,
                onImagePicked: { image in
                    pickerSourceType = nil
                    selectedImage = image
                    viewModel.reset()
                    showAnalysisSheet = true
                },
                onCancel: {
                    pickerSourceType = nil
                }
            )
        }
        .sheet(isPresented: $showAnalysisSheet) {
            if let image = selectedImage {
                BugAnalysisView(
                    image: image,
                    viewModel: viewModel,
                    onSaved: { result in
                        let insect = CapturedInsect(
                            commonName: result.commonName,
                            scientificName: result.scientificName,
                            bugResult: result
                        )
                        if let path = InsectStore.saveImage(image, id: insect.id) {
                            let withImage = CapturedInsect(
                                id: insect.id,
                                commonName: insect.commonName,
                                scientificName: insect.scientificName,
                                capturedAt: insect.capturedAt,
                                imagePath: path,
                                bugResult: result
                            )
                            onInsectCaptured(withImage)
                        } else {
                            onInsectCaptured(insect)
                        }
                    }
                )
                .interactiveDismissDisabled(!viewModel.canDismiss)
            }
        }
        .onChange(of: showAnalysisSheet) { _, isPresented in
            if !isPresented {
                selectedImage = nil
                viewModel.reset()
            }
        }
        .overlay {
            if let error = cameraService.setupError {
                VStack(spacing: 16) {
                    Text(error)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func capturePhoto() async {
        guard !isCapturing else { return }
        isCapturing = true
        defer { isCapturing = false }

        if let image = await cameraService.capturePhoto() {
            selectedImage = image
            viewModel.reset()
            showAnalysisSheet = true
        }
    }
}
