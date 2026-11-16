//
//  OrganizationModel.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import Foundation

enum OrganizationDetailTab: String, CaseIterable {
    case overview = "Overview"
    case officers = "Officers"
    case requirements = "Requirements"
    case activities = "Activities"
}

struct Officer: Identifiable {
    var id = UUID()
    var name: String
    var position: String
    var photo: String

    init(name: String, position: String, photo: String = "") {
        self.name = name
        self.position = position
        self.photo = photo
    }
}

struct RequirementItem: Identifiable {
    var id = UUID()
    var text: String

    init(text: String) {
        self.text = text
    }
}

struct StudentOrganization: Identifiable {
    var id = UUID()
    var name: String
    var type: String
    var memberCount: String
    var aboutUs: String
    var campus: String
    var founded: String
    var officers: [Officer]
    var requirements: [RequirementItem]
    var applicationPeriod: String
    var applicationHours: String
    var activities: [Post]
    var shortName: String
    var bannerImage: String
    var logoImage: String
    var shortDescription: String

    init(name: String, type: String, memberCount: String, aboutUs: String, campus: String, founded: String, officers: [Officer], requirements: [RequirementItem], applicationPeriod: String, applicationHours: String, activities: [Post], shortName: String? = nil, bannerImage: String = "", logoImage: String = "", shortDescription: String = "Representing the voice of the student body and promotes student welfare and participation.") {
        self.shortName = shortName ?? name
        self.bannerImage = bannerImage
        self.logoImage = logoImage
        self.shortDescription = shortDescription
        self.name = name
        self.type = type
        self.memberCount = memberCount
        self.aboutUs = aboutUs
        self.campus = campus
        self.founded = founded
        self.officers = officers
        self.requirements = requirements
        self.applicationPeriod = applicationPeriod
        self.applicationHours = applicationHours
        self.activities = activities
    }
}
