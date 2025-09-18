//
//  CourseVM.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Combine
import Constants


class CourseVM: ObservableObject, Identifiable {
    @Published var id = UUID()
    @Published var title: String
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var status: CourseStatus?
    
    
    
    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, status: CourseStatus? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
    }
    
    
    
    func isCurrent() -> Bool {
        return Date() >= startDate && Date() <= endDate
    }
    
    func isLater() -> Bool {
        return Date() < startDate
    }
    
    func isPassed() -> Bool {
        return Date() > endDate
    }
    
    
    func color() -> Color {
        if isLater() { return .drapGray }
        
        switch status {
        case .present:
            return .drapCyan
        case .signed:
            return .drapGreen
        case .absent:
            return .drapRed
        default:
            if isPassed() {
                return .drapBrown
            }
            return .drapBlue
        }
    }
    
    
    func description() -> String {
        if isLater() { return "Pas encore..." }
        
        switch status {
        case .present:
            return "Vous avez été mis présent"
        case .signed:
            return "Vous êtes présent"
        case .absent:
            return "Vous êtes absent"
        default:
            if isPassed() {
                return "Une erreur s'est produite"
            }
            return "Vous pouvez signer"
        }
    }
    
    
    func icone() -> String {
        if isLater() { return "circle" }
        
        switch status {
        case .present:
            return "checkmark"
        case .signed:
            return "checkmark"
        case .absent:
            return "xmark"
        default:
            if isPassed() {
                return "circle"
            }
            return "clock"
        }
    }
    
    
    func timeIntervalString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH'h'mm"
        formatter.locale = Locale(identifier: "fr_FR")
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        return "\(startString) - \(endString)"
    }
    
    
    enum CourseStatus {
        case present, signed, absent
    }
    
}
