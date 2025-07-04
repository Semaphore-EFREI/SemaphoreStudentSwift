//
//  FuturPage.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Constants


struct FuturPage: View {
    var body: some View {
        DrapNavigationStack(title: "À Venir", backgroundColor: .drapQuaternaryBackground) {
            print()
        } content: {
            Text("Hello")
                .frame(maxWidth: .infinity)
        }

    }
}




#Preview {
    PreviewScaffold(disablePadding: true) {
        FuturPage()
    }
}
