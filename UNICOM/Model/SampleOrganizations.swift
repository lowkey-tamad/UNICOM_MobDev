//
//  SampleOrganizations.swift
//  EucomCampusFeed
//
//  Demo organizations that ship with the app. Pictures come from Assets.xcassets.
//

import Foundation

enum SampleOrganizations {
    private static func officers() -> [Officer] {
        [
            Officer(name: "Juan Dela Cruz", position: "President", photo: "avatar_juan"),
            Officer(name: "Maria Santos", position: "Vice President", photo: "avatar_maria"),
            Officer(name: "Kristel Reyes", position: "Secretary", photo: "avatar_kristel"),
            Officer(name: "Angela Garcia", position: "Treasurer", photo: "avatar_angela"),
            Officer(name: "Carlos Mendoza", position: "Auditor", photo: "avatar_carlos"),
            Officer(name: "Isabella Torres", position: "P.R.O.", photo: "avatar_isabella")
        ]
    }

    private static func requirements() -> [RequirementItem] {
        [
            RequirementItem(text: "Must be a currently enrolled MSEUF student"),
            RequirementItem(text: "Must have a good academic standing (no failing grades)"),
            RequirementItem(text: "Willing to participate in the organization's activities and responsibilities")
        ]
    }

    private static func org(name: String, shortName: String, type: String, about: String,
                            founded: String, banner: String, logo: String, activities: [Post]) -> StudentOrganization {
        StudentOrganization(
            name: name, type: type, memberCount: "1.2k", aboutUs: about,
            campus: "MSEUF Main Campus", founded: founded,
            officers: officers(), requirements: requirements(),
            applicationPeriod: "Sept 1, 2026 - Sept 30, 2026", applicationHours: "12:00 AM - 11:59 PM",
            activities: activities,
            shortName: shortName, bannerImage: banner, logoImage: logo
        )
    }

    static let all: [StudentOrganization] = [
        StudentOrganization(
            name: "University Collegiate Student Council",
            type: "University Organization",
            memberCount: "1.2k",
            aboutUs: "The University Collegiate Student Council (UCSC) is the official student governing body of Manuel S. Enverga University Foundation. We represent the voice of the student body, organize activities, and work hand in hand with university administration to promote student welfare, leadership, and participation.",
            campus: "MSEUF Main Campus",
            founded: "1996",
            officers: officers(),
            requirements: [
                RequirementItem(text: "Be part of the University Collegiate Student Council"),
                RequirementItem(text: "Must be a currently enrolled MSEUF student"),
                RequirementItem(text: "Must have a good academic standing (no failing grades)"),
                RequirementItem(text: "Willing to participate in the organization's activities and responsibilities")
            ],
            applicationPeriod: "Sept 1, 2025 - Sept 30, 2025",
            applicationHours: "12:00 AM - 11:59 PM",
            activities: [
                SamplePosts.usc,
                SamplePosts.ucscAssembly,
                SamplePosts.ucscWeek,
                SamplePosts.ucscScholarship
            ],
            shortName: "USCS",
            bannerImage: "org_uscs_banner",
            logoImage: "org_uscs_logo"
        ),
        org(name: "Pet Society", shortName: "Pet Society", type: "University Organization",
            about: "Pet Society promotes responsible pet ownership and animal welfare across the MSEUF campus.",
            founded: "2023", banner: "org_pet_banner", logo: "org_pet_logo", activities: [SamplePosts.petSociety]),
        org(name: "Mastech", shortName: "Mastech", type: "Department Organization",
            about: "Mastech is the association of multimedia artists and technologists of the College of Computing and Multimedia Studies.",
            founded: "—", banner: "org_mastech_banner", logo: "org_mastech_logo", activities: [SamplePosts.mastech]),
        org(name: "Chess Society", shortName: "Chess Society", type: "University Organization",
            about: "The MSEUF Chess Society brings together chess players of all levels for friendly games, training, and tournaments.",
            founded: "—", banner: "org_chess_banner", logo: "org_chess_logo", activities: []),
        org(name: "Communication Society", shortName: "Communication Society", type: "Department Organization",
            about: "The MSEUF Communication Society brings together students who love media, storytelling, and communication.",
            founded: "—", banner: "org_com_banner", logo: "org_com_logo", activities: [SamplePosts.communication]),
        org(name: "Hospitality Management Society", shortName: "Hospitality Management Society", type: "Department Organization",
            about: "The society of the College of International Hospitality and Tourism Management.",
            founded: "—", banner: "org_hospi_banner", logo: "org_hospi_logo", activities: [SamplePosts.hospitality])
    ]
}
