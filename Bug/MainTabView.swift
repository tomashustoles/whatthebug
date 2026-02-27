//
//  MainTabView.swift
//  Bug
//
//  Bug ID — Root navigation with native iOS 26 Liquid Glass tab bar
//

import SwiftUI

struct MainTabView: View {
    @State private var insectStore = InsectStore()
    
    var body: some View {
        TabView {
            Tab("Scan", systemImage: "camera.fill") {
                ScanView(onInsectCaptured: { insect in
                    insectStore.add(insect: insect)
                })
            }
            
            Tab("Collection", systemImage: "rectangle.stack.fill") {
                CollectionView(insectStore: insectStore)
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView(insectStore: insectStore)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
