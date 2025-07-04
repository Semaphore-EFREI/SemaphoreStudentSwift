//
//  PastPage.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Constants


struct PastPage: View {
    var body: some View {
        DrapNavigationStack(title: "Passé", backgroundColor: .drapSecondaryBackground) {
            print()
        } content: {
            Text("Hello")
                .frame(maxWidth: .infinity)
        }

    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        PastPage()
    }
}
