import Foundation

enum AccountType: String, CaseIterable {
    case student = "Student"
    case employee = "Employee"

    var idPlaceholder: String {
        self == .employee ? "Enter your employee number..." : "Enter your student number..."
    }

    var idIcon: String {
        self == .employee ? "person.badge.key" : "person.text.rectangle"
    }

    // Students give course + year; employees give their position.
    var detailPlaceholder: String {
        self == .employee ? "Enter your position..." : "Course and year (e.g. BSCS 2nd Year)..."
    }

    var detailIcon: String {
        self == .employee ? "briefcase" : "book"
    }
}

struct UserAccount {
    var fullName: String
    var role: String
    var studentId: String
    var department: String
    var yearLevel: String
    var organizationName: String
    var email: String
    var phoneNumber: String
    var birthday: String
    var avatarURL: String
    var requestedRole: String

    // Employees stay `role = Student` on the server until approved, so also check what they signed up as.
    var isEmployee: Bool { role == "Employee" || requestedRole == "Employee" }

    init(fullName: String, role: String, studentId: String, department: String, yearLevel: String, organizationName: String, email: String, phoneNumber: String, birthday: String, avatarURL: String = "", requestedRole: String = "") {
        self.fullName = fullName
        self.role = role
        self.studentId = studentId
        self.department = department
        self.yearLevel = yearLevel
        self.organizationName = organizationName
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.avatarURL = avatarURL
        self.requestedRole = requestedRole
    }

    init() {
        self.init(fullName: "", role: "Student", studentId: "", department: "", yearLevel: "", organizationName: "", email: "", phoneNumber: "", birthday: "")
    }
}

// MARK: - Supabase rows

// Row from the `profiles` table (the signed-in user's own profile)
struct ProfileRecord: Codable {
    var fullName: String
    var email: String
    var role: String
    var studentId: String
    var department: String
    var yearLevel: String
    var organizationName: String
    var birthday: String
    var avatarUrl: String
    var requestedRole: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case requestedRole = "requested_role"
        case email, role
        case studentId = "student_id"
        case department
        case yearLevel = "year_level"
        case organizationName = "organization_name"
        case birthday
        case avatarUrl = "avatar_url"
    }
}

// Only the fields the user may edit (role and student_id are never sent)
struct ProfileUpdate: Encodable {
    var fullName: String
    var department: String
    var yearLevel: String
    var birthday: String

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case department
        case yearLevel = "year_level"
        case birthday
    }
}

// Row from the `public_profiles` view (safe fields of other users)
struct PublicProfile: Codable, Identifiable {
    var id: UUID
    var fullName: String
    var role: String
    var department: String
    var yearLevel: String
    var avatarUrl: String
    var organizationName: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case organizationName = "organization_name"
        case fullName = "full_name"
        case role, department
        case yearLevel = "year_level"
        case avatarUrl = "avatar_url"
    }
}
