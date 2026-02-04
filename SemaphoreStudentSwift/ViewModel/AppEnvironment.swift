//
//  AppEnvironment.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 03/02/2026.
//

import SwiftUI
import Faisceau
import CryptoKit


@Observable
class AppEnvironment {
    
    // MARK: Attributes
    
    @ObservationIgnored @AppStorage("userLogin") var login: String = ""
    @ObservationIgnored @AppStorage("userPassword") var password: String = ""
    @ObservationIgnored @AppStorage("userToken") var token: String = ""
    @ObservationIgnored @AppStorage("userRefreshToken") var refreshToken: String = ""
    @ObservationIgnored @AppStorage("accountKey") var accountKey: String = ""
    var api: FaisceauAPI
    
    var student: FaisceauStudent?
    var courses: [CourseVM] = []
    
    var loading = false
    var connected = false
    
    
    // MARK: init
    
    init() {
        self.api = FaisceauAPI()
        connect()
    }
    
    init(userLogin: FaisceauLoginInput) {
        self.login = userLogin.email
        self.password = userLogin.password
        self.token = userLogin.accessToken ?? ""
        self.refreshToken = userLogin.refreshToken ?? ""
        self.api = FaisceauAPI()
        connect()
    }
    
    
    
    // MARK: Methods
    
    var loginInput: FaisceauLoginInput {
        FaisceauLoginInput(
            email: login,
            password: password,
            accessToken: api.sessionTokens?.accessToken,
            refreshToken: api.sessionTokens?.refreshToken
        )
    }
    
    
    func connect() {
        guard login != "" && password != "" else { return }
        loading = true
        Task {
            do {
                let sessionTokens = try await api.connect(loginInput)
                let studentData = try await api.getStudent()
                await MainActor.run {
                    self.token = sessionTokens.accessToken
                    self.refreshToken = sessionTokens.refreshToken
                    self.student = studentData
                    self.connected = true
                    loading = false
                    registerDevice()
                }
                
                if let key = CryptoTools.loadPrivateKey(key: accountKey) {
                    let bly = try await api.getBuzzLightyearCode(deviceHeaders: FaisceauDeviceHeaders(
                        deviceId: studentData.device?.id,
                        deviceTimestamp: Int64(Date().timeIntervalSince1970),
                        deviceSignature: CryptoTools.signSecuredMessage(key: key, method: "GET", path: "/signature/buzzlightyear", studentId: studentData.id, deviceId: studentData.device?.id ?? UUID(), timestamp: Int64(Date().timeIntervalSince1970), body: Data("".utf8), challenge: "")
                    ))
                    
                    print("\n\n\(bly)\n\n")
                }
            } catch {
                print("ERREUR - AppEnvironment (connect()): \(error)")
                await MainActor.run {
                    loading = false
                }
            }
        }
    }
    
    
    func disconnect() {
        self.login = ""
        self.password = ""
        self.token = ""
        self.refreshToken = ""
        self.connected = false
    }
    
    
    func registerDevice() {
        guard let student, student.device == nil || student.device?.createdAt ?? Date() < Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 1209600) else { return }
        loading = true
        let keys = CryptoTools.generateP256Keys()
        
        let privateKeyString = keys.privateKey.rawRepresentation.base64EncodedString()
        let publicKeyString = keys.publicKey.rawRepresentation.base64EncodedString()
        
        Task {
            do {
                let _ = try await api.assignStudentDevice(studentId: student.id, device: FaisceauDeviceAssignment(
                    name: UIDevice.current.name,
                    publicKey: publicKeyString
                ))
                let reloadedStudent = try await api.getStudent()
                
                await MainActor.run {
                    self.accountKey = privateKeyString
                    self.student = reloadedStudent
                    loading = false
                }
            } catch {
                print("ERREUR - AppEnvironment (registerDevice()): \(error)")
                await MainActor.run {
                    loading = false
                }
            }
        }
    }
    
    
    func loadCourses() {
        Task {
            do {
                let newCourses = try await api.getCoursesNext20Days()
                await MainActor.run {
                    self.courses = newCourses.map { CourseVM(faisceauCourse: $0) }
                }
            } catch {
                print("ERREUR (CourseVM - loadCourses()) : \(error)")
            }
        }
    }
    
    
    func getRecoveries() -> [CourseVM] {
        guard let student else { return [] }
        return courses.filter { $0.mySignature(userId: student.id)?.status == .present }
    }
}
