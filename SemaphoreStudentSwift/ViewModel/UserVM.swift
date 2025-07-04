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
}
