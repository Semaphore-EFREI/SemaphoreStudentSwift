//
//  UserVM.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Combine


class UserVM: ObservableObject {
    
    // MARK: Attributes
    
    @Published var currentCourses: [CourseGetDTO] = []
    @Published var todayCourses: [CourseGetDTO] = []
    @Published var pastCourses: [CourseGetDTO] = []
    @Published var futurCourses: [CourseGetDTO] = []
    
    private var apiClient: APIClient
    
    
    
    // MARK: Init
    
    init() {
        let url = URL(string: "https://semaphore.lebonnec.uk/api")
        self.apiClient = APIClient(baseURL: url!)
    }

    // MARK: - Network

    /// Fetch the courses for the authenticated student and sort them
    @MainActor
    func fetchCourses() async {
        do {
            // Request courses with the associated student signatures
            let courses = try await apiClient.getCourses(include: ["studentSignatures"])
            sortCourses(courses)
        } catch {
            print("Failed to fetch courses: \(error)")
        }
    }

    // MARK: - Helpers

    /// Sort courses by date in past, today or future and mark current ones
    @MainActor
    private func sortCourses(_ courses: [CourseGetDTO]) {
        let calendar = Calendar.current
        let now = Date()

        var current: [CourseGetDTO] = []
        var today: [CourseGetDTO] = []
        var past: [CourseGetDTO] = []
        var futur: [CourseGetDTO] = []

        for course in courses {
            let isToday = calendar.isDate(course.date, inSameDayAs: now)

            // Determine if the course should be considered ongoing
            let isCurrentTime = (course.date...course.endDate).contains(now)
            let hasPresentSignature = course.studentSignatures?.contains(where: { $0.status == .present }) ?? false
            let isCurrent = isToday && (isCurrentTime || hasPresentSignature)

            if isCurrent {
                current.append(course)
            } else if isToday {
                today.append(course)
            } else if course.endDate < now {
                past.append(course)
            } else if course.date > now {
                futur.append(course)
            } else {
                // Fallback for cross-day courses
                if course.endDate < now {
                    past.append(course)
                } else {
                    futur.append(course)
                }
            }
        }

        // Sort each section by start date
        current.sort { $0.date < $1.date }
        today.sort { $0.date < $1.date }
        past.sort { $0.date < $1.date }
        futur.sort { $0.date < $1.date }

        self.currentCourses = current
        self.todayCourses = today
        self.pastCourses = past
        self.futurCourses = futur
    }
}
