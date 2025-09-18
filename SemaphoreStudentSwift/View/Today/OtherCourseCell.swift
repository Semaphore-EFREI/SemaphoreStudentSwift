//
//  OtherCourseCell.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Constants


struct OtherCourseCell: View {
    
    var course: CourseVM
    
    
    var body: some View {
        CourseRow(title: course.title, time: course.timeIntervalString(), classroom: "A001", color: course.color(), isSelected: course.isCurrent())
    }
}





#Preview {
    OtherCourseCell(course: Courses.values[0])
}
