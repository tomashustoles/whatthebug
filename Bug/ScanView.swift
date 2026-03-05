//
//  ScanView.swift
//  Bug
//
//  Bug ID — Camera scan screen
//

import SwiftUI

struct ScanView: View {
    var onInsectCaptured: (CapturedInsect) -> Void = { _ in }
    
    @State private var selectedImage: UIImage?
    @State private var showAnalysisSheet = false
    @State private var pickerSourceType: CameraPickerView.SourceType?
    @State private var isShowingSheet = false  // Prevent multiple sheet presentations
    @State private var sheetID = UUID()  // Force sheet to be unique instance
    @State private var analysisViewModel: BugAnalysisViewModel?  // Persistent ViewModel
    @StateObject private var cameraService = CameraCaptureService()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var oneTimeUnlockManager = OneTimeUnlockManager.shared
    @State private var scanLimitManager = ScanLimitManager.shared
    @State private var isCapturing = false
    @State private var showLimitAlert = false
    @State private var showPaywall = false  // For paywall sheet
    @State private var usedScanCredit = false  // Track if current scan used a credit
    
    // Calculate total scans remaining (daily limit + credits)
    private var totalScansRemaining: Int {
        if purchaseManager.isPro {
            return 999 // Show infinity for Pro
        }
        return scanLimitManager.scansRemaining + oneTimeUnlockManager.availableScanCredits
    }

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

                        // Scan counter (Liquid Glass circle) - only for non-Pro users
                        if !purchaseManager.isPro {
                            Button {
                                showPaywall = true
                            } label: {
                                scanCounterView
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear
                                .frame(width: 56, height: 56)
                        }
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
                    print("[ScanView] Image picked from library, size: \(image.size)")
                    pickerSourceType = nil
                    
                    // Guard against multiple sheet presentations
                    guard !isShowingSheet else {
                        print("[ScanView] Already showing sheet, ignoring duplicate request")
                        return
                    }
                    
                    if scanLimitManager.canScan(isPro: purchaseManager.isPro) || oneTimeUnlockManager.hasScanCredits {
                        selectedImage = image
                        isShowingSheet = true
                        
                        // Create viewModel BEFORE showing sheet
                        analysisViewModel = BugAnalysisViewModel()
                        sheetID = UUID()  // Generate new ID for new sheet instance
                        print("[ScanView] Created new ViewModel and scheduling sheet with new ID")
                        
                        // Use a longer delay to ensure picker is fully dismissed
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                            print("[ScanView] Showing analysis sheet now")
                            showAnalysisSheet = true
                        }
                        
                        // Increment counter or use credit
                        if !purchaseManager.isPro {
                            if scanLimitManager.canScan(isPro: false) {
                                // Using FREE daily scan (1/3, 2/3, or 3/3)
                                scanLimitManager.incrementScanCount()
                                usedScanCredit = false  // ❌ Free scan - NO auto-unlock
                                print("[ScanView] Used free daily scan")
                            } else {
                                // Using PAID scan credit (after free scans exhausted)
                                let creditUsed = oneTimeUnlockManager.useScanCredit()
                                usedScanCredit = creditUsed  // ✅ Paid credit - WILL auto-unlock
                                print("[ScanView] Used PAID scan credit: \(creditUsed)")
                            }
                        } else {
                            // Pro subscriber - unlimited scans, no credits needed
                            usedScanCredit = false  // No credit used (subscription covers it)
                            print("[ScanView] Pro user - unlimited access")
                        }
                    } else {
                        showLimitAlert = true
                    }
                },
                onCancel: {
                    print("[ScanView] Image picker cancelled")
                    pickerSourceType = nil
                }
            )
        }
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("Upgrade to Pro", role: .none) {
                showPaywall = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You've used all 3 daily scans. Upgrade to Pro for unlimited scans!")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
        .sheet(isPresented: $showAnalysisSheet) {
            if let image = selectedImage, let viewModel = analysisViewModel {
                BugAnalysisView(
                    image: image,
                    viewModel: viewModel,
                    onSaved: { result in
                        print("[ScanView] Analysis saved, creating CapturedInsect")
                        
                        // If this scan used a credit, automatically unlock the insect
                        if usedScanCredit {
                            oneTimeUnlockManager.unlockInsect(result.id)
                            print("[ScanView] Auto-unlocked insect \(result.commonName) (ID: \(result.id)) because scan credit was used")
                        }
                        
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
                            print("[ScanView] Calling onInsectCaptured with saved image")
                            onInsectCaptured(withImage)
                        } else {
                            print("[ScanView] Calling onInsectCaptured without image")
                            onInsectCaptured(insect)
                        }
                    }
                )
                .interactiveDismissDisabled(!viewModel.canDismiss)
            }
        }
        .onChange(of: showAnalysisSheet) { oldValue, isPresented in
            print("[ScanView] showAnalysisSheet changed from \(oldValue) to \(isPresented)")
            if !isPresented {
                print("[ScanView] Sheet dismissed, clearing state")
                selectedImage = nil
                analysisViewModel = nil
                isShowingSheet = false
                usedScanCredit = false  // Reset the credit flag
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
        guard !isShowingSheet else {
            print("[ScanView] Already showing analysis sheet, ignoring capture")
            return
        }
        
        // Check scan limit before capturing (including credits)
        if !scanLimitManager.canScan(isPro: purchaseManager.isPro) && !oneTimeUnlockManager.hasScanCredits {
            showLimitAlert = true
            return
        }
        
        isCapturing = true
        defer { isCapturing = false }

        if let image = await cameraService.capturePhoto() {
            selectedImage = image
            isShowingSheet = true
            
            // Create viewModel BEFORE showing sheet
            analysisViewModel = BugAnalysisViewModel()
            sheetID = UUID()  // Generate new ID for new sheet instance
            print("[ScanView] Photo captured, created new ViewModel, showing analysis sheet")
            // Reset will happen when sheet appears via task
            showAnalysisSheet = true
            
            // Increment counter or use credit
            if !purchaseManager.isPro {
                if scanLimitManager.canScan(isPro: false) {
                    // Using FREE daily scan (1/3, 2/3, or 3/3)
                    scanLimitManager.incrementScanCount()
                    usedScanCredit = false  // ❌ Free scan - NO auto-unlock
                    print("[ScanView] Used free daily scan")
                } else {
                    // Using PAID scan credit (after free scans exhausted)
                    let creditUsed = oneTimeUnlockManager.useScanCredit()
                    usedScanCredit = creditUsed  // ✅ Paid credit - WILL auto-unlock
                    print("[ScanView] Used PAID scan credit: \(creditUsed)")
                }
            } else {
                // Pro subscriber - unlimited scans, no credits needed
                usedScanCredit = false  // No credit used (subscription covers it)
                print("[ScanView] Pro user - unlimited access")
            }
        }
    }
    
    private var scanCounterView: some View {
        ZStack {
            // Counter text with strong shadow
            VStack(spacing: 2) {
                Text("\(totalScansRemaining)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.9), radius: 1, x: 0, y: 0)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
                
                Text("left")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.9), radius: 1, x: 0, y: 0)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
            }
            .zIndex(10)  // Force text to be on top
        }
        .frame(width: 56, height: 56)
        .glassEffect(.regular, in: .circle)
    }
}
