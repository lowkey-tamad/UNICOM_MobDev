//
//  Departments.swift
//  EucomCampusFeed
//

import Foundation

enum Departments {
    static let students = [
        "CENG", "CCJC", "CCMS", "CED", "CAS", "CNAHS",
        "CIHTM", "CAFA", "CME", "BED", "CBA"
    ]

    // Employees/faculty get every college plus the offices below.
    static let employees = students + [
        "CSCJPS", "Alumni", "IGSR", "GSD", "Procurement", "DCAVRKMI", "ICTD",
        "Legal Registrar's Office", "Admission Office", "OSAS", "HRD",
        "University Libraries", "EMRC", "UCSC"
    ]

    static func list(for type: AccountType) -> [String] {
        type == .employee ? employees : students
    }
}
