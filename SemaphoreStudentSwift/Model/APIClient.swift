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
        
        Task {
            do {
                let token = try await authenticateStudent(email: "", password: "")
                await MainActor.run {
                    self.token = token.token
                }
            } catch {}
        }
    }
    
    
    
    // MARK: Methods
    
    private func makeRequest(_ path: String, method: String, query: [URLQueryItem]? = nil, body: Data? = nil) -> URLRequest {
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

    // Example authentication call
    public func authenticateBeacon(beaconId: UUID, timestamp: Int64, signature: String) async throws -> TokenGroupDTO {
        struct Body: @MainActor Codable {
            let beaconId: UUID
            let timestamp: Int64
            let signature: String
        }
        let bodyData = try JSONEncoder().encode(Body(beaconId: beaconId, timestamp: timestamp, signature: signature))
        return try await send("beacon/auth/token", method: "POST", query: nil, body: bodyData)
    }

    // MARK: - Student Endpoints

    /// Authenticate a student and store the received token
    public func authenticateStudent(email: String, password: String) async throws -> TokenGroupDTO {
        struct Body: @MainActor Codable {
            let userType: String
            let email: String
            let password: String
        }
        let bodyData = try JSONEncoder().encode(Body(userType: "student", email: email, password: password))
        let tokens: TokenGroupDTO = try await send("auth/token", method: "POST", query: nil, body: bodyData)
        self.token = tokens.token
        return tokens
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
