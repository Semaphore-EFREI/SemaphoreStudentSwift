//
//  MainPage.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 19/09/2025.
//

import SwiftUI
import Drapeau
import Styles
import Faisceau


struct MainPage: View {
    
    // MARK: Attributes
    
    @Environment(AppEnvironment.self) var appEnvironment
    @State var showSettingsPage = false
    
    
    // MARK: View
    
    var body: some View {
        DrapNavigationView { date in
            ScrollView {
                cardList(selectedDate: date)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettingsPage = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                    }
                }
            }
        } hasData: { date in
            appEnvironment.courses.first { course in
                date.isSameDay(course.date)
            } != nil
        } refreshAction: {
            appEnvironment.loadCourses()
        }
        .fullScreenCover(isPresented: $showSettingsPage) {
            SettingsPage(
                firstName: appEnvironment.student?.firstname ?? "",
                lastName: appEnvironment.student?.lastname ?? "",
                userRole: .student,
                deviceLinkedToOtherDevice: false
            ) {
                showSettingsPage = false
            } disconnectAction: {
                appEnvironment.disconnect()
            }
        }
    }
    
    
    @ViewBuilder
    func cardList(selectedDate: Date) -> some View {
        Group {
            let courses = appEnvironment.courses.filter({ $0.date.isSameDay(selectedDate) })
            if !courses.isEmpty  {
                VStack(spacing: -216) {
                    ForEach(courses, id: \.id) { course in
                        NavigationLink {
                            CourseDetailPage(course: course)
                        } label: {
                            CourseCard(infos: CourseViewInfos(
                                name: course.name,
                                status: course.status(userId: appEnvironment.student?.id ?? UUID()),
                                startDate: course.date,
                                endDate: course.endDate,
                                place: course.classrooms?.map(\.name).joined(separator: ", ") ?? "Visio",
                                signatureEndDate: Date(timeIntervalSince1970: course.date.timeIntervalSince1970 + Double(course.signatureClosingDelay * 60)),
                                hasMessages: false,
                                signature: "")
                            )
                            .courseCardShadow()
                        }

                    }
                }
                .padding()
            } else {
                VStack {
                    Text("Noooooon !\nRiiien de riiien !")
                        .multilineTextAlignment(.center)
                        .drapImportantDescription()
                        .foregroundStyle(Color.drapSecondaryText)
                }
                .frame(height: 300)
            }
        }
    }
}




#Preview {
    PreviewScaffold(disablePadding: true) {
        MainPage()
            .environment(AppEnvironment())
    }
}
