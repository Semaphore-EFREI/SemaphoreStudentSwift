//
//  CurrentCourseCell.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Drapeau
import Constants


struct CurrentCourseCell: View {
    
    @EnvironmentObject var drapManager: DrapContextWindowManager
    @ObservedObject var userVM: UserVM
    @StateObject var nfcVM = NFCReaderViewModel()
    @StateObject var flashVM = FlashVM()
    var course: CourseVM
    
    
    var body: some View {
        CourseCell(courseTitle: course.title, description: course.description(), accentColor: course.color(), icon: course.icone(), firstButton: button1(), secondButton: nil)
    }
    
    
    func button1() -> (() -> DrapButton)? {
        if course.isLater() { return nil }
        
        switch course.status {
        case .present:
            return {DrapButton(icon: "signature", title: "Signer", tint: .drapCyan, kind: .primary) {
                print()
            }}
        case .signed:
            return nil
        case .absent:
            return {DrapButton(icon: "dollarsign.circle", title: "Soudoyer le prof", tint: .drapRed, kind: .primary) {
                print("")
            }}
        default:
            if course.isPassed() {
                return nil
            }
            return {DrapButton(icon: "signature", title: "Signer", tint: .drapBlue, kind: .primary) {
                drapManager.present(userVM.nfcView(drapManager: drapManager, nfcVM: nfcVM, flashVM: flashVM))
            }}
        }
    }
}





#Preview {
    PreviewScaffold(disablePadding: true) {
        CurrentCourseCell(userVM: UserVM(), course: Courses.values[0])
    }
}
