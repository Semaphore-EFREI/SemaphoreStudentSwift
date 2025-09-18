//
//  Courses.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI

class Courses {
    static var values: [CourseVM] = [
        CourseVM(title: "Controle Commandes",
                 startDate: Date(timeIntervalSince1970: 1751522400),
                 endDate: Date(timeIntervalSince1970: 1751530800),
                 status: .signed
                ),
        CourseVM(title: "Eco Conception Electronique",
                 startDate: Date(timeIntervalSince1970: 1751531400),
                 endDate: Date(timeIntervalSince1970: 1751495400),
                 status: .signed
                ),
        CourseVM(title: "Systemes Embarques Avancees",
                 startDate: Date(timeIntervalSince1970: 1751543400),
                 endDate: Date(timeIntervalSince1970: 1751551200),
                 status: .absent
                ),
        CourseVM(title: "Vision Robotique et Analyse",
                 startDate: Date(timeIntervalSince1970: 1751699400),
                 endDate: Date(timeIntervalSince1970: 1751711400)
                ),
        CourseVM(title: "Robotique Mobile Avancee",
                 startDate: Date(timeIntervalSince1970: 1751716200),
                 endDate: Date(timeIntervalSince1970: 1751724000)
                ),
        CourseVM(title: "IA et ROS",
                 startDate: Date(timeIntervalSince1970: 1751728200),
                 endDate: Date(timeIntervalSince1970: 1751736600)
                ),
        CourseVM(title: "Gestion de projet",
                 startDate: Date(timeIntervalSince1970: 1751608800),
                 endDate: Date(timeIntervalSince1970: 1751614200),
                 status: .signed
                ),
        CourseVM(title: "Management",
                 startDate: Date(timeIntervalSince1970: 1751614800),
                 endDate: Date(timeIntervalSince1970: 1751625000)
                ),
        CourseVM(title: "English Project",
                 startDate: Date(timeIntervalSince1970: 1751629800),
                 endDate: Date(timeIntervalSince1970: 1751637600)
                ),
    ]
}
