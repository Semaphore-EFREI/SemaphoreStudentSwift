//
//  ContentView.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Constants


struct ContentView: View {
    
    // MARK: Attributes
    
    @StateObject var userVM = UserVM()
    @State var value: Int = 1
    
    
    
    // MARK: View
    
    var body: some View {
        TabView(selection: $value) {
            Tab("Passé", systemImage: "arrow.left", value: 0) {
                PastPage(userVM: userVM)
            }
            
            Tab("Aujourd'hui", systemImage: "calendar", value: 1) {
                TodayPage(userVM: userVM)
            }
            
            Tab("À Venir", systemImage: "arrow.right", value: 2) {
                FuturPage(userVM: userVM)
            }
        }
        .tint(.drapBlue)
    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        ContentView(userVM: UserVM())
    }
}
