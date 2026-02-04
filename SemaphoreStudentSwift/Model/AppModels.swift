//
//  AppModels.swift
//  SemaphoreStudentSwift
//
//  Created by Codex on 03/02/2026.
//

import SwiftUI
import Observation
import Faisceau
import Drapeau
import Styles


// MARK: - Session

@MainActor
@Observable
class SessionViewModel {
    var login: String = ""
    var password: String = ""
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    func restore(using environment: AppEnvironment) async {
        guard !isAuthenticated else { return }
        login = environment.login
        password = environment.password

        let hasStoredLogin = !environment.login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasRefreshToken = !environment.refreshToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPassword = !environment.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        guard hasStoredLogin && (hasRefreshToken || hasPassword) else { return }
        await connect(using: environment)
    }

    func signIn(using environment: AppEnvironment) async {
        login = login.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        environment.login = login
        environment.password = password
        await connect(using: environment)
    }

    func connect(using environment: AppEnvironment) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let tokens = try await environment.api.connect(environment.loginInput)
            environment.refreshToken = tokens.refreshToken
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            errorMessage = "Connexion impossible. Vérifiez vos identifiants."
        }

        isLoading = false
    }

    func signOut(using environment: AppEnvironment) {
        environment.login = ""
        environment.password = ""
        environment.refreshToken = ""
        environment.api = FaisceauAPI()
        isAuthenticated = false
        errorMessage = nil
    }
}


// MARK: - Courses

enum CourseSignatureState: String {
    case signed
    case present
    case absent
    case late
    case excused
    case invalid
}

struct CourseItem: Identifiable, Hashable {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let place: String
    let signatureEndDate: Date
    let hasMessages: Bool
    let status: CourseStatus
    let signatureState: CourseSignatureState?
    let isOnline: Bool

    var isCurrentTime: Bool {
        Date().isBetween(startDate, and: endDate)
    }

    var isCurrentBySignature: Bool {
        signatureState == .present
    }

    var canSign: Bool {
        status == .now || status == .late
    }

    var timeRangeText: String {
        "\(startDate.drapTime) - \(endDate.drapTime)"
    }

    var signatureCountdownText: String {
        let remaining = signatureEndDate.timeIntervalSince(Date())
        guard remaining > 0 else { return "Temps écoulé" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        formatter.allowedUnits = remaining >= 3600 ? [.hour, .minute] : [.minute]
        formatter.calendar = Calendar.current
        formatter.zeroFormattingBehavior = .dropAll
        if let text = formatter.string(from: remaining) {
            return "\(text) pour signer"
        }
        return "Temps écoulé"
    }
}

struct DayCourseSections {
    var current: [CourseItem]
    var upcoming: [CourseItem]
    var past: [CourseItem]
}

@MainActor
@Observable
class CoursesViewModel {
    var courses: [CourseItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    func load(using environment: AppEnvironment) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await environment.api.getCoursesNext20Days()
            let currentUserId = environment.api.currentUser?.id
            let mapped = fetched.map { mapCourse($0, currentUserId: currentUserId) }
            courses = mapped.sorted { $0.startDate < $1.startDate }
        } catch {
            errorMessage = "Impossible de charger les cours."
        }

        isLoading = false
    }

    func hasCourses(on date: Date) -> Bool {
        courses.contains { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }

    func courses(on date: Date) -> [CourseItem] {
        courses.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.startDate < $1.startDate }
    }

    func sections(for date: Date) -> DayCourseSections {
        let dayCourses = courses(on: date)
        guard Calendar.current.isDateInToday(date) else {
            if date < Date().startOfDay {
                return DayCourseSections(current: [], upcoming: [], past: dayCourses)
            }
            return DayCourseSections(current: [], upcoming: dayCourses, past: [])
        }

        let now = Date()
        let current = dayCourses.filter { $0.isCurrentTime || $0.isCurrentBySignature }
            .sorted { $0.startDate < $1.startDate }

        let remaining = dayCourses.filter { !current.contains($0) }
        let past = remaining.filter { $0.endDate < now }
            .sorted { $0.startDate > $1.startDate }
        let upcoming = remaining.filter { $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }

        return DayCourseSections(current: current, upcoming: upcoming, past: past)
    }

    private func mapCourse(_ course: FaisceauCourse, currentUserId: String?) -> CourseItem {
        let startDate = Date(timeIntervalSince1970: TimeInterval(course.date))
        let endDate = Date(timeIntervalSince1970: TimeInterval(course.endDate))
        let signatureEndDate = startDate.addingTimeInterval(TimeInterval(course.signatureClosingDelay) * 60)
        let place = course.classrooms?.first?.name ?? (course.isOnline ? "En ligne" : "Salle inconnue")
        let signature = resolveSignature(course.signatures, currentUserId: currentUserId)
        let signatureState = CourseSignatureState(rawValue: signature?.status ?? "")
        let status = resolveStatus(signatureState: signatureState, startDate: startDate, endDate: endDate, signatureEndDate: signatureEndDate)

        return CourseItem(
            id: course.id,
            name: course.name,
            startDate: startDate,
            endDate: endDate,
            place: place,
            signatureEndDate: signatureEndDate,
            hasMessages: false,
            status: status,
            signatureState: signatureState,
            isOnline: course.isOnline
        )
    }

    private func resolveSignature(_ signatures: [FaisceauSignature]?, currentUserId: String?) -> FaisceauSignature? {
        guard let signatures, !signatures.isEmpty else { return nil }
        if let currentUserId {
            if let match = signatures.first(where: { $0.studentId == currentUserId }) {
                return match
            }
        }
        return signatures.first
    }

    private func resolveStatus(signatureState: CourseSignatureState?, startDate: Date, endDate: Date, signatureEndDate: Date) -> CourseStatus {
        if let signatureState {
            switch signatureState {
            case .signed:
                return .present
            case .present:
                return .presentToken
            case .late:
                return .late
            case .absent, .excused:
                return .absent
            case .invalid:
                return .error
            }
        }

        let now = Date()
        if now < startDate {
            return .later
        }
        if now <= endDate {
            return now > signatureEndDate ? .late : .now
        }
        return .absent
    }
}


// MARK: - Date Helpers

extension Date {
    var drapTime: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "HH'h'mm"
        return formatter.string(from: self)
    }

    func isBetween(_ start: Date, and end: Date) -> Bool {
        if start < end {
            return (start ... end).contains(self)
        }
        return (end ... start).contains(self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
