//
//  UserVM.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Combine
import Drapeau
import Constants


class UserVM: ObservableObject {
    
    // MARK: Attributes
    
    @Published var currentCourses: [CourseVM] = []
    @Published var todayCourses: [CourseVM] = []
    @Published var pastCourses: [CourseVM] = []
    @Published var futurCourses: [CourseVM] = []
    
    
    
    // MARK: Init
    
    init() {
        self.loadCourses()
    }

    
    
    // MARK: Methods
    
    func loadCourses() {
        self.groupCourses(Courses.values)
    }
    
    
    func groupCourses(_ courses: [CourseVM]) {
        let calendar = Calendar.current
        let now = Date()
        
        // Début et fin de la journée courante
        let todayStart = calendar.startOfDay(for: now)
        let todayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart)!
        
        let passed = courses.filter { $0.endDate < todayStart }
        let today = courses.filter {
            // Cours qui commencent ou finissent aujourd'hui
            calendar.isDate($0.startDate, inSameDayAs: now) ||
            calendar.isDate($0.endDate, inSameDayAs: now)
        }
        let current = courses.filter { $0.isCurrent() }
        let future = courses.filter { $0.startDate > todayEnd }
        
        self.pastCourses = passed
        self.todayCourses = today
        self.currentCourses = current
        self.futurCourses = future
    }
    
    
    
    // MARK: Signature
    
    
    func nfcView(drapManager: DrapContextWindowManager, nfcVM: NFCReaderViewModel, flashVM: FlashVM) -> ContextWindow<Text> {
        return ContextWindow<Text>(image: "iPhone sur Balise", description: "Appuyez sur “Scanner la balise” et collez votre appareil sur celle-ci") {
            ContextMenuBar {
                DrapButton(icon: "chevron.left", title: "Annuler", tint: .drapPrimaryText, kind: .small) {
                    drapManager.dismiss()
                }
            } trailing: {
                DrapButton(icon: "flashlight.off.fill", tint: .drapPrimaryText, kind: .small) {
                    drapManager.dismiss()
                }
            }
        } actionButton: {
            DrapButton(icon: "square.split.diagonal.fill", title: "Scanner la balise", tint: .drapBlue, kind: .primaryRounded) {
                Task {
                    let _ = await nfcVM.scanForNFCMessage()
                    await MainActor.run {
                        drapManager.present(self.signature(drapManager: drapManager))
                    }
                }
            }
        }
    }
    
    
    func flashView(drapManager: DrapContextWindowManager, nfcVM: NFCReaderViewModel, flashVM: FlashVM) -> ContextWindow<Text> {
        return ContextWindow<Text>(image: "iPhone sur Balise", description: "Appuyez sur “Scanner la balise” et collez votre appareil sur celle-ci") {
            ContextMenuBar {
                DrapButton(icon: "chevron.left", title: "Annuler", tint: .drapPrimaryText, kind: .small) {
                    drapManager.dismiss()
                }
            } trailing: {
                DrapButton(icon: "flashlight.off.fill", tint: .drapPrimaryText, kind: .small) {
                    drapManager.dismiss()
                }
            }
        } actionButton: {
            DrapButton(icon: "square.split.diagonal.fill", title: "Scanner la balise", tint: .drapBlue, kind: .primaryRounded) {
                Task {
                    let _ = await nfcVM.scanForNFCMessage()
                    await MainActor.run {
                        drapManager.present(self.signature(drapManager: drapManager))
                    }
                }
            }
        }
    }
    
    
    func signature(drapManager: DrapContextWindowManager) -> ContextWindow<Text> {
        self.currentCourses[0].status = .signed
        return ContextWindow<Text>(image: "Présent", description: "Vous êtes présent !") {
            ContextMenuBar()
        } actionButton: {
            DrapButton(title: "Ok", tint: .drapGreen, kind: .primaryRounded) {
                drapManager.dismiss()
            }
        }
    }
}
