//
//  CollectionView.swift
//  Bug
//
//  Bug ID — Gallery view of captured insects
//

import SwiftUI
import UIKit

struct CollectionView: View {
    @Bindable var insectStore: InsectStore
    @State private var selectedInsect: CapturedInsect?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            if insectStore.insects.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(insectStore.insects) { insect in
                        InsectCard(insect: insect)
                            .onTapGesture {
                                guard insect.imagePath != nil else { return }
                                selectedInsect = insect
                            }
                    }
                }
                .padding(24)
                .padding(.bottom, 120)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.black)
        .sheet(item: $selectedInsect) { insect in
            InsectDetailSheet(insect: insect, insectStore: insectStore)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 80)
            
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            Text("Your Collection")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Insects you capture and identify will appear here")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InsectDetailSheet: View {
    let insect: CapturedInsect
    @Bindable var insectStore: InsectStore
    @State private var viewModel = BugAnalysisViewModel()

    var body: some View {
        if let path = insect.imagePath,
           let image = UIImage(contentsOfFile: path) {
            BugAnalysisView(
                image: image,
                viewModel: viewModel,
                onSaved: insect.bugResult == nil ? { result in
                    insectStore.updateBugResult(for: insect, result)
                } : nil,
                existingResult: insect.bugResult
            )
            .interactiveDismissDisabled(!viewModel.canDismiss)
        }
    }
}

private struct InsectCard: View {
    let insect: CapturedInsect
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if let path = insect.imagePath,
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .overlay {
                            Image(systemName: "ant.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.tertiary)
                        }
                }
            }
            .frame(height: 140)
            .clipped()
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 14,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 14
                )
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insect.commonName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(insect.scientificName)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .italic()
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 14,
                    bottomTrailingRadius: 14,
                    topTrailingRadius: 0
                )
                .fill(Color(white: 0.12))
            }
        }
    }
}
