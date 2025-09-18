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
    
    @ObservedObject var userVM: UserVM
    
    
    
    var body: some View {
        DrapNavigationStack(title: "À Venir", backgroundColor: .drapQuaternaryBackground) {
            print()
        } content: {
            VStack(spacing: 4) {
                ForEach(userVM.futurCourses) { course in
                    OtherCourseCell(course: course)
                }
            }
        }

    }
}




#Preview {
    PreviewScaffold(disablePadding: true) {
        FuturPage(userVM: UserVM())
    }
}
