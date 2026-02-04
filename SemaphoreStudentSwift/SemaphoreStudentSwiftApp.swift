//
//  SemaphoreStudentSwiftApp.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau


@main
struct SemaphoreStudentSwiftApp: App {
    
    @State var appEnvironment = AppEnvironment()
    
    
    var body: some Scene {
        WindowGroup {
            DrApp {
                Group {
                    ContentView()
                }
            }
        }
        .environment(appEnvironment)
    }
}
