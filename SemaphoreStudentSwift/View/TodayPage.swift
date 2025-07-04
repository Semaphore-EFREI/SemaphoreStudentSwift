//
//  TodayPage.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau


struct TodayPage: View {
    
    @EnvironmentObject var drapManager: DrapContextWindowManager
    
    
    var body: some View {
        DrapNavigationStack(title: "Aujourd'hui") {
            print()
        } content: {
            DrapButton(title: "Essai") {
                drapManager.present(
                    ContextWindow(menuBar: {
                    ContextMenuBar()
                    }, content: {
                        Text("test")
                    }),
                    direction: .backward)
            }
        }

    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        TodayPage()
    }
}
