import Foundation

public enum SignatureStatus: String, Codable {
    case signed, present, absent
}

public enum SignatureMethod: String, Codable {
    case beacon, buzzLightyear, qrCode, teacher, web, `self`
}

public enum AdministratorRole: String, Codable {
    case planning, absence, manager
}

public struct TokenGroupDTO: Codable {
    public let token: String
    public let refreshToken: String
}

public struct ErrorDTO: Codable, Error {
    public let code: String
    public let message: String
}

public struct BeaconGetDTO: Codable {
    public let id: UUID
    public let serialNumber: Int32
    public let totpKey: String?
    public let classroom: UUID?
    public let programVersion: String?
}

public struct ClassroomGetDTO: Codable {
    public let id: UUID
    public let name: String
    public let school: UUID
    public let beacons: [BeaconGetDTO]?
}

public struct CourseGetDTO: Codable {
    public let id: UUID
    public let name: String
    public let date: Date
    public let endDate: Date
    public let isOnline: Bool
    public let signatureClosingDelay: Int
    public let signatureClosed: Bool
    public let school: UUID?
    public let classrooms: [ClassroomGetDTO]?
    public let studentSignatures: [StudentSignatureGetDTO]?
    public let teacherSignatures: [TeacherSignatureGetDTO]?
}

public struct SchoolPreferencesGetDTO: Codable {
    public let id: UUID
    public let defaultSignatureClosingDelay: Int
    public let teacherCanModifyClosingDelay: Bool
    public let studentsCanSignBeforeTeacher: Bool
    public let nfcEnabled: Bool
    public let flashlightEnabled: Bool
    public let qrCodeEnabled: Bool
}

public struct SchoolGetDTO: Codable {
    public let id: UUID
    public let name: String
    public let preferences: UUID?
}

public struct SchoolGetExpandedDTO: Codable {
    public let id: UUID
    public let name: String
    public let preferences: SchoolPreferencesGetDTO
}

public struct TeacherGetDTO: Codable {
    public let id: UUID
    public let firstname: String
    public let lastname: String
    public let email: String
    public let passwordHash: String?
    public let createdOn: Date
    public let school: UUID?
}

public struct StudentGetDTO: Codable {
    public let id: UUID
    public let firstname: String
    public let lastname: String
    public let email: String
    public let passwordHash: String?
    public let createdOn: Date
    public let school: UUID?
    public let studentNumber: Int32
}

public struct AdministratorGetDTO: Codable {
    public let id: UUID
    public let firstname: String
    public let lastname: String
    public let email: String
    public let passwordHash: String?
    public let createdOn: Date
    public let school: UUID?
    public let role: AdministratorRole
}

public struct StudentGroupGetDTO: Codable {
    public let id: UUID
    public let name: String
    public let singleStudentGroup: Bool
    public let school: UUID?
    public let courses: [CourseGetDTO]?
    public let students: [StudentGetDTO]?
}

public struct TeacherSignatureGetDTO: Codable {
    public let id: UUID
    public let date: Date
    public let course: UUID
    public let status: SignatureStatus
    public let image: String?
    public let method: SignatureMethod
    public let teacher: UUID
}

public struct StudentSignatureGetDTO: Codable {
    public let id: UUID
    public let date: Date
    public let course: UUID
    public let status: SignatureStatus
    public let image: String?
    public let method: SignatureMethod
    public let student: UUID
    public let teacher: UUID?
    public let administrator: UUID?
}

/// Empty response used for endpoints returning no body
public struct EmptyResponse: Codable {}

/// Payload to create a student signature
public struct StudentSignaturePostDTO: Codable {
    public var id: UUID?
    public var date: Date
    public var course: UUID
    public var status: SignatureStatus
    public var image: String?
    public var method: SignatureMethod
    public var student: UUID
    public var teacher: UUID?
    public var administrator: UUID?
}

/// Payload to patch a student signature
public struct StudentSignaturePatchDTO: Codable {
    public var date: Date?
    public var course: UUID?
    public var status: SignatureStatus?
    public var image: String?
    public var method: SignatureMethod?
    public var student: UUID?
    public var teacher: UUID?
    public var administrator: UUID?
}
