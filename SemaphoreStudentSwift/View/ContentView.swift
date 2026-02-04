//
//  ContentView.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Styles


struct ContentView: View {
    
    // MARK: Attributes
    
    @Environment(AppEnvironment.self) var appEnvironment
    
    
    // MARK: View
    
    var body: some View {
        if appEnvironment.loading {
            ZStack {
                Color.drapPrimaryBackground.ignoresSafeArea()
                Text("Chargement")
                    .drapImportantDescription()
                    .foregroundStyle(Color.drapTertiaryText)
            }
        } else if !appEnvironment.connected {
            LoginPage(login: appEnvironment.$login, password: appEnvironment.$password, userRole: .student) {
                appEnvironment.connect()
            }
            .onChange(of: appEnvironment.password) { oldValue, newValue in
                print(newValue)
            }
        } else {
            MainPage()
                .onAppear {
                    appEnvironment.loadCourses()
                }
        }
    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        ContentView()
            .environment(AppEnvironment())
    }
}
