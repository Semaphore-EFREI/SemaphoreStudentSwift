//
//  TodayPage.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Combine


struct TodayPage: View {
    
    @EnvironmentObject var drapManager: DrapContextWindowManager
    @ObservedObject var userVM: UserVM
    
    
    var body: some View {
        DrapNavigationStack(title: "Aujourd'hui") {
            print()
        } refreshAction: {
            userVM.loadCourses()
        } content: {
            content
        }
    }
    
    
    var content: some View {
        VStack(spacing: 24) {
            VStack(spacing: 24) {
                ForEach(userVM.currentCourses) { course in
                    CurrentCourseCell(userVM: userVM, course: course)
                }
            }
            
            VStack(spacing: 4) {
                ForEach(userVM.todayCourses) { course in
                    OtherCourseCell(course: course)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        TodayPage(userVM: UserVM())
    }
}
