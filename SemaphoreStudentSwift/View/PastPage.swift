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
    
    @ObservedObject var userVM: UserVM
    
    
    var body: some View {
        DrapNavigationStack(title: "Passé", backgroundColor: .drapSecondaryBackground) {
            print()
        } content: {
            VStack(spacing: 4) {
                ForEach(userVM.pastCourses) { course in
                    OtherCourseCell(course: course)
                }
            }
        }

    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        PastPage(userVM: UserVM())
    }
}
