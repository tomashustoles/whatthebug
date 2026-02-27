//
//  ProfileView.swift
//  Bug
//
//  Bug ID — Profile with Subscription and Insects sections
//

import SwiftUI

struct ProfileView: View {
    @Bindable var insectStore: InsectStore
    @State private var isSubscribed = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Subscription section
                VStack(alignment: .leading, spacing: 16) {
                    Text("SUBSCRIPTION")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    subscriptionCard
                }
                
                // Insects section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("INSECTS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(insectStore.insects.count) captured")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                    
                    insectsList
                }
            }
            .padding(24)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(Color.black)
    }
    
    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                if isSubscribed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSubscribed ? "Active" : "Premium")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(isSubscribed ? "Your subscription is active" : "Unlock unlimited identifications")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Button {
                isSubscribed.toggle()
            } label: {
                Text(isSubscribed ? "Manage" : "Subscribe")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(isSubscribed ? Color(white: 0.25) : Color.accentColor)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.12))
        }
    }
    
    private var insectsList: some View {
        Group {
            if insectStore.insects.isEmpty {
                emptyInsectsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(insectStore.insects) { insect in
                        InsectRow(insect: insect)
                            .contextMenu {
                                Button(role: .destructive) {
                                    insectStore.remove(insect: insect)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var emptyInsectsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "ant.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            Text("No insects captured yet")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text("Use Scan to photograph and identify insects")
                .font(.system(size: 15))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(48)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.08))
        }
    }
}

private struct InsectRow: View {
    let insect: CapturedInsect
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail or placeholder
            Group {
                if let path = insect.imagePath,
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "ant.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insect.commonName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(insect.scientificName)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .italic()
                
                Text(insect.capturedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.12))
        }
    }
}
