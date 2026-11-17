//
//  SamplePosts.swift
//  EucomCampusFeed
//
//  Demo posts that ship with the app. Pictures come from Assets.xcassets.
//  Likes and comments on them are saved on the device (see AppState), not in Supabase.
//

import Foundation

enum SamplePosts {
    private static func make(key: String, author: String, role: String, verified: Bool, avatar: String?,
                             time: String, hoursAgo: Double, body: String, image: String?,
                             org: String = "", official: Bool = false, comments: Int = 12,
                             audience: PostAudience = .campus) -> Post {
        var post = Post(authorName: author, authorRole: role, isVerified: verified, timeAgo: time,
                        body: body, likeCount: 240, commentCount: comments, isOfficial: official)
        post.isSample = true
        post.audience = audience
        post.sampleKey = key
        post.createdAt = Date().addingTimeInterval(-hoursAgo * 3600)
        post.localAvatarName = avatar
        post.localImageName = image
        post.organizationName = org
        return post
    }

    // MARK: - Organization screen
    static let petSociety = make(key: "org-pet", author: "Pet Society", role: "University Organization", verified: true,
                                 avatar: "org_pet_logo", time: "2h", hoursAgo: 2,
                                 body: "It's Meow-ntal Health Month!", image: "post_mental_pet", org: "Pet Society")
    static let usc = make(key: "org-usc", author: "USC_Official", role: "University Organization", verified: true,
                          avatar: "org_uscs_logo", time: "2h", hoursAgo: 2,
                          body: "wear blue shirts every Wednesday of October", image: "post_mental_oct", org: "USCS")
    static let mastech = make(key: "org-mastech", author: "Mastech", role: "Department Organization", verified: true,
                              avatar: "org_mastech_logo", time: "2h", hoursAgo: 2,
                              body: "Lenovo Legion Campus Quest is coming! Join us on October 13, 2026.", image: "post_lenovo", org: "Mastech")
    static let hospitality = make(key: "org-hospi", author: "Hospitality Management Society", role: "Department Organization", verified: true,
                                  avatar: "org_hospi_logo", time: "2h", hoursAgo: 2,
                                  body: "COFFEE ALERT, CONQUERORS!", image: "post_coffee", org: "Hospitality Management Society")
    static let communication = make(key: "org-com", author: "Communication Society", role: "Department Organization", verified: true,
                                    avatar: "org_com_logo", time: "2h", hoursAgo: 2,
                                    body: "Tara, COMMustahan tayo, mga COMMpare at COMMare!", image: "post_commustahan", org: "Communication Society")

    static let organizationFeed: [Post] = [petSociety, usc, mastech, hospitality, communication]

    // Extra posts shown in the University Collegiate Student Council's Activities tab
    static let ucscAssembly = make(key: "ucsc-assembly", author: "UCSC_Official", role: "University Organization", verified: true,
                                   avatar: "org_uscs_logo", time: "3h", hoursAgo: 3,
                                   body: "General Assembly for all MSEUF Students\nJoin us this Friday, September 12, 2026 at the MSEUF Gymnasium. Your presence is highly encouraged",
                                   image: nil, org: "USCS", official: true)
    static let ucscWeek = make(key: "ucsc-week", author: "UCSC_Events", role: "University Organization", verified: true,
                               avatar: "org_uscs_logo", time: "1d", hoursAgo: 24,
                               body: "MSEUF Week 2026: Opening Day\nLet's kick off MSEUF Week with a bang! Games, performances, and more await you!",
                               image: nil, org: "USCS", official: true)
    static let ucscScholarship = make(key: "ucsc-scholarship", author: "UCSC_Scholarship", role: "University Organization", verified: true,
                                      avatar: "org_uscs_logo", time: "3d", hoursAgo: 72,
                                      body: "Apply Now: Student Leader Scholarship\nOpen for all qualified and experienced student leaders. Deadline: Sept 30, 2026",
                                      image: nil, org: "USCS", official: true, comments: 15)

    // MARK: - Main dashboard
    static let dashboard: [Post] = [
        make(key: "dash-1", author: "Angelo Sarmiento", role: "BSCS 2nd Year", verified: false, avatar: "avatar_angelo",
             time: "2h", hoursAgo: 2, body: "Open for Commissions! ✏️", image: "post_commission", audience: .social),
        make(key: "dash-2", author: "USC_Official", role: "University Organization", verified: true, avatar: "org_uscs_logo",
             time: "5h", hoursAgo: 5,
             body: "World Mental Health Month.\nwe encourage all college students to wear blue shirts every Wednesday of October",
             image: nil),
        make(key: "dash-3", author: "University_Admin", role: "University Admin", verified: true, avatar: "avatar_admin",
             time: "2h", hoursAgo: 2, body: "14-Day Intensive Training", image: "post_euflight"),
        make(key: "dash-4", author: "Aljin Robis", role: "BSCS 2nd Year", verified: false, avatar: "avatar_carlos",
             time: "2h", hoursAgo: 2, body: "Peram Calcu!!!\nNeed lang po for examination balik ko din! THANKK YOUU!! <33", image: nil, audience: .social),
        make(key: "dash-5", author: "University_Admin", role: "University Admin", verified: true, avatar: "avatar_admin",
             time: "3h", hoursAgo: 3, body: "Happy Teacher's day! 🎉", image: "happening_teachers_day"),
        make(key: "dash-6", author: "Vince Davit", role: "BSCS 2nd Year", verified: false, avatar: "avatar_angela",
             time: "3h", hoursAgo: 3,
             body: "Looking for this kind of book!\nBka po meron kayong kakilala nag bebenta or nag papaharam ng gantong book. Thank you po!",
             image: "post_book", audience: .social)
    ]

    // Every sample post once (AppState keeps the live, interactive copies).
    static let all: [Post] = dashboard + organizationFeed + [ucscAssembly, ucscWeek, ucscScholarship]
}
