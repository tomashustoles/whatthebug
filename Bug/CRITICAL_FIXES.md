# Critical Fixes: Image Loading & Cancelled Error

## Problem 1: Images Not Displaying in Collection ❌ → ✅

### Symptoms
- Insects appear in Collection tab with placeholder bug icons
- Image metadata (common name, scientific name) displays correctly  
- Actual photos don't load
- Issue persists after app rebuild/restart

### Root Cause
**iOS Sandbox Path Changes**: When an iOS app is rebuilt or reinstalled, the app's sandbox directory path changes. The Documents directory path that was valid in the previous installation becomes invalid in the new one.

Example:
```
Old path: /var/.../Containers/Data/Application/ABC123/Documents/InsectImages/UUID.jpg
New path: /var/.../Containers/Data/Application/XYZ789/Documents/InsectImages/UUID.jpg
          ↑ Different container ID after rebuild ↑
```

The **filename** (`UUID.jpg`) remains the same, but the **container path** changes.

### Solution Implemented

#### 1. Path Migration on Load (InsectStore.swift)
Added intelligent path migration logic that:
- Checks if existing paths are still valid
- Extracts filename from old paths
- Reconstructs paths using current Documents directory
- Automatically updates and saves corrected paths

```swift
private func load() {
    // ... decode insects ...
    
    for i in decoded.indices where decoded[i].imagePath != nil {
        let oldPath = decoded[i].imagePath!
        
        // Check if current path is valid
        if FileManager.default.fileExists(atPath: oldPath) {
            continue
        }
        
        // Extract filename and rebuild path
        let filename = URL(fileURLWithPath: oldPath).lastPathComponent
        let newURL = documentsDir
            .appendingPathComponent("InsectImages")
            .appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: newURL.path) {
            decoded[i].imagePath = newURL.path  // Migrate to new path
        } else {
            decoded[i].imagePath = nil  // File truly missing
        }
    }
    
    // Save with updated paths
    save()
}
```

#### 2. Enhanced Debug Logging
Added console output to track:
- When images are saved successfully
- When paths are migrated
- When image files are not found

```swift
static func saveImage(_ image: UIImage, id: UUID) -> String? {
    // ... save logic ...
    print("[InsectStore] Saved image: \(url.path)")
    return url.path
}
```

#### 3. Helper Method for Current Paths
Added utility method (ready for future use):
```swift
static func currentPath(for filename: String) -> String?
```

### Result
✅ Images now load correctly after app rebuilds  
✅ Existing collections are automatically migrated  
✅ Debug logging helps track file operations  
✅ Graceful fallback to placeholder if file truly missing

---

## Problem 2: "IDENTIFICATION FAILED cancelled" Error ❌ → ✅

### Symptoms
- After capturing/selecting an image, sheet shows "IDENTIFICATION FAILED cancelled"
- User taps sheet, data suddenly appears correctly
- Happens consistently, especially on second+ scans
- Confusing user experience

### Root Cause
**ViewModel State Pollution**: The `BugAnalysisViewModel` was being reused across multiple analyses:

1. **First scan**: ViewModel created in `@State` → Analysis completes → Success ✓
2. **User dismisses sheet** → ViewModel still exists with old state
3. **Second scan**: Same ViewModel instance reused
4. **Race condition**: Old state might flash before new analysis starts
5. **Task cancellation**: If timing is off, Swift Task gets cancelled during presentation
6. **CancellationError displayed**: "cancelled" error shown to user

Additional issues:
- `viewModel.reset()` called at wrong times (before sheet presents, after dismissal)
- Task cancellation errors not properly filtered
- No delay for sheet presentation animation to complete

### Solution Implemented

#### 1. Create Fresh ViewModel Per Analysis (ScanView.swift)
**Before:**
```swift
@State private var viewModel = BugAnalysisViewModel()  // ❌ Reused
...
.sheet(isPresented: $showAnalysisSheet) {
    BugAnalysisView(image: image, viewModel: viewModel)  // ❌ Same instance
}
```

**After:**
```swift
// ✅ No viewModel in @State
...
.sheet(isPresented: $showAnalysisSheet) {
    let viewModel = BugAnalysisViewModel()  // ✅ NEW instance each time
    BugAnalysisView(image: image, viewModel: viewModel)
}
```

#### 2. Improved Task Management (BugAnalysisView.swift)
```swift
.onAppear {
    guard existingResult == nil else { return }
    
    viewModel.reset()
    
    // Start analysis with delay for sheet presentation
    analysisTask = Task { @MainActor in
        // Wait for sheet animation to complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        
        guard !Task.isCancelled else { return }
        
        await viewModel.analyze(image: image)
    }
}

.onDisappear {
    // Clean up task when sheet dismissed
    analysisTask?.cancel()
    analysisTask = nil
}
```

#### 3. Better Cancellation Handling (BugAnalysisViewModel.swift)
```swift
func analyze(image: UIImage) async {
    state = .loading
    
    do {
        let result = try await visionService.analyzeImage(image)
        try Task.checkCancellation()
        state = .success(result)
        
    } catch is CancellationError {
        // Don't show error UI - view is being dismissed anyway
        print("[BugAnalysisViewModel] Task was cancelled - ignoring")
        return
        
    } catch {
        // Also catch "cancelled" in error messages
        if error.localizedDescription.contains("cancelled") {
            return
        }
        state = .error(error.localizedDescription)
    }
}
```

#### 4. Removed Premature Reset Calls
**Before:**
```swift
.onChange(of: showAnalysisSheet) { _, isPresented in
    if !isPresented {
        selectedImage = nil
        viewModel.reset()  // ❌ Wrong timing
    }
}
```

**After:**
```swift
.onChange(of: showAnalysisSheet) { _, isPresented in
    if !isPresented {
        selectedImage = nil  // ✅ Clean up image only
        // ViewModel auto-released when sheet dismissed
    }
}
```

### Result
✅ No more "cancelled" error messages  
✅ Smooth loading → success transitions  
✅ Each scan gets fresh ViewModel state  
✅ Proper task lifecycle management  
✅ Better resource cleanup  
✅ Debug logging for troubleshooting

---

## Technical Details

### Files Modified
1. **InsectStore.swift** - Path migration and debug logging
2. **BugAnalysisView.swift** - Task management and lifecycle
3. **BugAnalysisViewModel.swift** - Cancellation handling and logging
4. **ScanView.swift** - Fresh ViewModel creation per analysis

### Testing Checklist
- [x] Images display after app rebuild
- [x] Images display for existing collections
- [x] No "cancelled" errors on first scan
- [x] No "cancelled" errors on subsequent scans
- [x] Sheet presents smoothly
- [x] Loading state shows immediately
- [x] Results appear without flashing
- [x] Dismissing during analysis doesn't crash
- [x] Console logs help debug issues

### Key Learnings

1. **iOS Sandbox Paths**: Always account for path changes between app installations
2. **ViewModel Lifecycle**: Create fresh state for independent operations
3. **SwiftUI Sheets**: Allow time for presentation animations before starting heavy work
4. **Task Cancellation**: Filter cancellation errors from user-facing UI
5. **Debug Logging**: Essential for diagnosing async timing issues

### Performance Impact
- ✅ Minimal - ViewModels are lightweight
- ✅ 0.1s delay is imperceptible to users
- ✅ Path migration happens once per app launch
- ✅ No impact on successful analysis flow

### Future Improvements
1. Consider using relative paths (filename only) + computed property for full path
2. Add image cache layer to avoid repeated disk reads
3. Consider showing "Preparing..." state during 0.1s delay
4. Add telemetry for cancellation frequency
