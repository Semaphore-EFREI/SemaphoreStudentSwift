import Foundation


public class APIClient {
    
    // MARK: Attributes
    
    public var baseURL: URL
    public var session: URLSession
    public var token: String?

    
    
    // MARK: Init
    
    public init(baseURL: URL, session: URLSession = .shared, token: String? = nil) {
        self.baseURL = baseURL
        self.session = session
        self.token = token
    }
    
    
    
    // MARK: Methods
    
    private func makeRequest(_ path: String, method: String, query: [URLQueryItem]? = nil, body: Data? = nil) -> URLRequest {
        print(path)
        var url = baseURL.appendingPathComponent(path)
        if let query, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems = query
            url = components.url ?? url
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        return request
    }
    

    @discardableResult
    public func send<T: Decodable>(_ path: String, method: String = "GET", query: [URLQueryItem]? = nil, body: Data? = nil) async throws -> T {
        let request = makeRequest(path, method: method, query: query, body: body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        print(http.statusCode)
        if (200..<300).contains(http.statusCode) {
            if T.self == EmptyResponse.self && data.isEmpty {
                return EmptyResponse() as! T
            }
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            if let apiError = try? JSONDecoder().decode(ErrorDTO.self, from: data) {
                throw apiError
            } else {
                throw URLError(.badServerResponse)
            }
        }
    }

    
    
    // MARK: - Student Endpoints

    /// Authenticate a student and store the received token
    public func authenticateStudent(email: String, password: String) async throws {
        struct Body: @MainActor Codable {
            let userType: String
            let email: String
            let password: String
        }
        let bodyData = try JSONEncoder().encode(Body(userType: "student", email: email, password: password))
        print("Body : \(bodyData.base64EncodedString())")
        print("Body : \(bodyData.base64EncodedString().utf8)")
        let tokens: TokenGroupDTO = try await send("auth/token", method: "POST", query: nil, body: bodyData)
        self.token = tokens.token
    }
    

    /// Return courses for the authenticated student
    public func getCourses(include: [String]? = nil) async throws -> [CourseGetDTO] {
        var query: [URLQueryItem]? = nil
        if let include { query = [URLQueryItem(name: "include", value: include.joined(separator: ","))] }
        return try await send("courses", query: query)
    }

    
    /// Get the signature status for a course
    public func getCourseStatus(courseId: UUID) async throws -> StudentSignatureGetDTO {
        try await send("course/\(courseId)/status")
    }

    
    /// Send a new signature for the student
    public func postSignature(_ signature: StudentSignaturePostDTO) async throws -> StudentSignatureGetDTO {
        let body = try JSONEncoder().encode(signature)
        return try await send("signature", method: "POST", body: body)
    }

    
    /// Patch an existing signature
    @discardableResult
    public func patchSignature(signatureId: UUID, patch: StudentSignaturePatchDTO) async throws -> EmptyResponse {
        let body = try JSONEncoder().encode(patch)
        return try await send("signature/\(signatureId)", method: "PATCH", body: body)
    }
    

    /// Get details about a school
    public func getSchool(schoolId: UUID, expand: [String]? = nil) async throws -> SchoolGetExpandedDTO {
        var query: [URLQueryItem]? = nil
        if let expand { query = [URLQueryItem(name: "expand", value: expand.joined(separator: ","))] }
        return try await send("school/\(schoolId)", query: query)
    }
    
    

    // MARK: - Student Endpoints

    /// Return courses for the authenticated student
    public func getCourses() async throws -> [CourseGetDTO] {
        return try await send("courses")
    }

    
    /// Get details about a school
    public func getSchool(schoolId: UUID) async throws -> SchoolGetExpandedDTO {
        return try await send("school/\(schoolId)")
    }
}
