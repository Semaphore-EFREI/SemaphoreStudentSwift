//
//  CourseVM.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/02/2026.
//

import Foundation
import Drapeau
import Faisceau


@Observable
class CourseVM {
    
    // MARK: Attributes
    
    var id: UUID
    var name: String
    var date: Date
    var endDate: Date
    var isOnline: Bool
    var signatureClosingDelay: Int
    var signatureClosed: Bool
    var classrooms: [FaisceauClassroom]?
    var signatures: [FaisceauSignature]?
    var teachers: [FaisceauTeacher]?
    var students: [FaisceauStudent]?
    var soloStudents: [FaisceauStudent]?
    var studentGroups: [FaisceauStudentGroup]?
    
    
    // MARK: Init
    
    init(id: UUID, name: String, date: Date, endDate: Date, isOnline: Bool, signatureClosingDelay: Int, signatureClosed: Bool, classrooms: [FaisceauClassroom]? = nil, signatures: [FaisceauSignature]? = nil, teachers: [FaisceauTeacher]? = nil, students: [FaisceauStudent]? = nil, soloStudents: [FaisceauStudent]? = nil, studentGroups: [FaisceauStudentGroup]? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.endDate = endDate
        self.isOnline = isOnline
        self.signatureClosingDelay = signatureClosingDelay
        self.signatureClosed = signatureClosed
        self.classrooms = classrooms
        self.signatures = signatures
        self.teachers = teachers
        self.students = students
        self.soloStudents = soloStudents
        self.studentGroups = studentGroups
    }
    
    init(faisceauCourse: FaisceauCourse) {
        self.id = faisceauCourse.id
        self.name = faisceauCourse.name
        self.date = Date(timeIntervalSince1970: Double(faisceauCourse.date))
        self.endDate = Date(timeIntervalSince1970: Double(faisceauCourse.endDate))
        self.isOnline = faisceauCourse.isOnline
        self.signatureClosingDelay = faisceauCourse.signatureClosingDelay
        self.signatureClosed = faisceauCourse.signatureClosed
        self.classrooms = faisceauCourse.classrooms
        self.signatures = faisceauCourse.signatures
        self.teachers = faisceauCourse.teachers
        self.students = faisceauCourse.students
        self.soloStudents = faisceauCourse.soloStudents
        self.studentGroups = faisceauCourse.studentGroups
    }
    
    
    
    // MARK: Methods
    
    func refresh(api: FaisceauAPI) {
        Task {
            do {
                let faisceauCourse = try await api.getCourseDetail(courseId: self.id)
                await MainActor.run {
                    self.name = faisceauCourse.name
                    self.date = Date(timeIntervalSince1970: Double(faisceauCourse.date))
                    self.endDate = Date(timeIntervalSince1970: Double(faisceauCourse.endDate))
                    self.isOnline = faisceauCourse.isOnline
                    self.signatureClosingDelay = faisceauCourse.signatureClosingDelay
                    self.signatureClosed = faisceauCourse.signatureClosed
                    self.classrooms = faisceauCourse.classrooms
                    self.signatures = faisceauCourse.signatures
                    self.teachers = faisceauCourse.teachers
                    self.students = faisceauCourse.students
                    self.soloStudents = faisceauCourse.soloStudents
                    self.studentGroups = faisceauCourse.studentGroups
                }
            } catch {
                print("ERREUR - CourseVM (refresh()): \(error)")
            }
        }
    }
    
    
    func mySignature(userId: UUID) -> FaisceauSignature? {
        signatures?.first { signature in
            signature.teacherId == userId || signature.studentId == userId
        }
    }
    
    
    func status(userId: UUID) -> CourseStatus {
        if let signature = mySignature(userId: userId) {
            return switch signature.status {
            case .absent: .absent
            case .justified: .absent
            case .late: .late
            case .present: .presentToken
            case .signed: .present
            case .none: .error
            }
        }
        
        if Date() < date { return .later }
        if Date().isBetween(Date(timeIntervalSince1970: date.timeIntervalSince1970 + Double(signatureClosingDelay * 60)), and: endDate) { return .late}
        if Date().isBetween(date, and: endDate) { return .now }
        return .error
    }
}
