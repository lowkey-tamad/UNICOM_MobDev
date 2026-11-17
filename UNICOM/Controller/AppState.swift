//
//  AppState.swift
//  EucomCampusFeed
//

import Foundation
import Combine
import Supabase

enum AuthStage {
    case onboarding
    case login
    case signUpAccount
    case signUpVerify
    case signUpComplete
    case main
}

// A comment a user wrote on a built-in sample post (kept on the device).
struct StoredSampleComment: Codable {
    var id: UUID
    var author: String
    var avatar: String
    var body: String
    var date: Date
}

@MainActor
final class AppState: ObservableObject {

    // MARK: - Session
    @Published var stage: AuthStage = .onboarding
    @Published var selectedTab: AppTab = .home
    @Published var viewedProfile: ProfileTarget? = nil   // another user's profile, shown full screen
    @Published var pendingConversationId: UUID? = nil    // conversation to open when the Messages tab appears
    @Published var postRoute: PostRoute? = nil           // post to show as a sheet
    @Published var isRestoring = true
    @Published var account = UserAccount()
    @Published var userId: UUID? = nil
    @Published var pendingEmail = ""

    // MARK: - Feed (loaded from Supabase)
    @Published var allPosts: [Post] = []
    @Published private var hiddenPostIds: Set<UUID> = []

    var visiblePosts: [Post] { allPosts.filter { !hiddenPostIds.contains($0.id) } }
    var campusPosts: [Post] { visiblePosts.filter { $0.audience == .campus } }
    var socialPosts: [Post] { visiblePosts.filter { $0.audience == .social } }
    // Home feed: the newest posts from all users on top, then the built-in sample posts.
    private func feed(_ audience: PostAudience?) -> [Post] {
        let real = visiblePosts
            .filter { audience == nil || $0.audience == audience }
            .sorted { $0.createdAt > $1.createdAt }
        let samples = dashboardSamplePosts.filter { audience == nil || $0.audience == audience }
        return real + samples
    }
    var allFeed: [Post] { feed(nil) }
    var campusFeed: [Post] { feed(.campus) }
    var socialFeed: [Post] { feed(.social) }

    var trendingPosts: [Post] {
        visiblePosts.sorted { ($0.likeCount, $0.createdAt) > ($1.likeCount, $1.createdAt) }
    }

    // MARK: - Messaging
    @Published var conversations: [Conversation] = []
    @Published var activeMessages: [ChatMessage] = []
    private(set) var activeConversationId: UUID? = nil
    var unreadMessages: Int { conversations.reduce(0) { $0 + $1.unreadCount } }

    // MARK: - Notifications
    @Published var notifications: [NotificationItem] = []
    var unreadNotifications: Int { notifications.filter { !$0.isRead }.count }

    // MARK: - Realtime
    private var realtimeChannel: RealtimeChannelV2?
    private var realtimeTasks: [Task<Void, Never>] = []

    // MARK: - Example data (not connected to Supabase yet)
    @Published var happeningNow = [
        Announcement(tag: "Announcement", title: "Class Suspension on Oct 15", subtitle: "Due to inclement weather",
                     source: "University Admin", imageName: "happening_class_suspension"),
        Announcement(tag: "Announcement", title: "Admissions now open", subtitle: "2nd Sem AY 2026-2027",
                     source: "University Admin", imageName: "happening_admissions"),
        Announcement(tag: "Event", title: "Teacher's Day 2026", subtitle: "Happy World Teachers' Day",
                     source: "University Admin", imageName: "happening_teachers_day")
    ]

    @Published var organizations = SampleOrganizations.all

    // MARK: - Sample (built-in) posts
    // Likes and comments on these are saved on this device (per account), not in Supabase.
    @Published var samplePosts: [Post] = SamplePosts.all
    private var sampleVotes: [String: Int] = [:]
    private var sampleComments: [String: [StoredSampleComment]] = [:]

    var dashboardSamplePosts: [Post] {
        samplePosts.filter { $0.sampleKey?.hasPrefix("dash-") == true }
    }

    var organizationSamplePosts: [Post] {
        SamplePosts.organizationFeed.map { live($0) }
    }

    // The interactive copy of a sample post (same post if it is not a sample).
    func live(_ post: Post) -> Post {
        guard let key = post.sampleKey else { return post }
        return samplePosts.first { $0.sampleKey == key } ?? post
    }

    private func sampleKey(for postId: UUID) -> String? {
        samplePosts.first { $0.id == postId }?.sampleKey
    }

    private var sampleSuffix: String { userId?.uuidString ?? "guest" }

    func loadSampleState() {
        let defaults = UserDefaults.standard
        sampleVotes = (defaults.dictionary(forKey: "sampleVotes.\(sampleSuffix)") as? [String: Int]) ?? [:]
        if let data = defaults.data(forKey: "sampleComments.\(sampleSuffix)"),
           let decoded = try? JSONDecoder().decode([String: [StoredSampleComment]].self, from: data) {
            sampleComments = decoded
        } else {
            sampleComments = [:]
        }
        samplePosts = SamplePosts.all.map { base in
            var post = base
            if let key = base.sampleKey {
                let vote = sampleVotes[key] ?? 0
                post.myVote = vote
                post.likeCount = base.likeCount + vote
                post.commentCount = base.commentCount + (sampleComments[key]?.count ?? 0)
            }
            return post
        }
    }

    private func voteOnSample(key: String, value: Int) {
        guard let index = samplePosts.firstIndex(where: { $0.sampleKey == key }) else { return }
        let old = samplePosts[index].myVote
        let new = (old == value) ? 0 : value
        samplePosts[index].likeCount += new - old
        samplePosts[index].myVote = new
        sampleVotes[key] = new
        UserDefaults.standard.set(sampleVotes, forKey: "sampleVotes.\(sampleSuffix)")
    }

    private func saveSampleComments() {
        if let data = try? JSONEncoder().encode(sampleComments) {
            UserDefaults.standard.set(data, forKey: "sampleComments.\(sampleSuffix)")
        }
    }

    // MARK: - Auth
    func restoreSession() async {
        defer { isRestoring = false }
        do {
            _ = try await supabase.auth.session
            try await bootstrap()
            stage = .main
        } catch {
            // no saved session, stay on onboarding
        }
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
        try await bootstrap()
        stage = .main
    }

    func signUp(fullName: String, email: String, studentId: String, role: String,
                department: String, yearLevel: String, password: String) async throws {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        _ = try await supabase.auth.signUp(
            email: cleanEmail,
            password: password,
            data: [
                "full_name": .string(fullName),
                "student_id": .string(studentId),
                "role": .string(role),
                "department": .string(department),
                "year_level": .string(yearLevel)
            ]
        )
        pendingEmail = cleanEmail
    }

    func verifyEmail(code: String) async throws {
        _ = try await supabase.auth.verifyOTP(email: pendingEmail, token: code, type: .signup)
        try await bootstrap()
    }

    func resendCode() async throws {
        _ = try await supabase.auth.resend(email: pendingEmail, type: .signup)
    }

    func changePassword(current: String, new: String) async throws {
        // Supabase doesn't check the old password on update, so verify it by signing in again
        let email = try await supabase.auth.session.user.email ?? account.email
        _ = try await supabase.auth.signIn(email: email, password: current)
        _ = try await supabase.auth.update(user: UserAttributes(password: new))
    }

    func signOut() async {
        await stopRealtime()
        try? await supabase.auth.signOut()
        userId = nil
        selectedTab = .home
        viewedProfile = nil
        postRoute = nil
        pendingConversationId = nil
        account = UserAccount()
        allPosts = []
        samplePosts = SamplePosts.all
        sampleVotes = [:]
        sampleComments = [:]
        conversations = []
        notifications = []
        activeMessages = []
        activeConversationId = nil
        stage = .login
    }

    // Loads everything the main screens need after a successful login
    private func bootstrap() async throws {
        let session = try await supabase.auth.session
        userId = session.user.id
        LocalNotifier.shared.onRoute = { [weak self] route in self?.route(to: route) }
        loadSampleState()
        try await loadProfile()
        await loadPosts()
        await loadConversations()
        await loadNotifications()
        await startRealtime()
        LocalNotifier.shared.requestPermission()
    }

    // MARK: - Profile
    func loadProfile() async throws {
        let id = try await supabase.auth.session.user.id
        let row: ProfileRecord = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        account = UserAccount(
            fullName: row.fullName, role: row.role, studentId: row.studentId,
            department: row.department, yearLevel: row.yearLevel,
            organizationName: row.organizationName, email: row.email,
            phoneNumber: "", birthday: row.birthday, avatarURL: row.avatarUrl,
            requestedRole: row.requestedRole ?? ""
        )
    }

    // Finds people by name in the safe `public_profiles` view. `%` and `_` typed by the user are matched literally.
    func searchProfiles(_ text: String) async -> [PublicProfile] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        let escaped = query
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
        do {
            let rows: [PublicProfile] = try await supabase
                .from("public_profiles")
                .select()
                .ilike("full_name", pattern: "%\(escaped)%")
                .limit(20)
                .execute()
                .value
            return rows
        } catch {
            print("search:", error)
            return []
        }
    }

    // MARK: - Routing (notification taps)
    func route(to route: AppRoute) {
        switch route {
        case .conversation(let id):
            viewedProfile = nil
            postRoute = nil
            selectedTab = .message
            pendingConversationId = id
        case .post(let id):
            if viewedProfile != nil {
                viewedProfile = nil
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    postRoute = PostRoute(id: id)
                }
            } else {
                postRoute = PostRoute(id: id)
            }
        }
    }

    // A row in the Notification list was tapped.
    func open(_ item: NotificationItem) {
        if let postId = item.postId {
            route(to: .post(postId))
        } else {
            selectedTab = .home
        }
    }

    func fetchPost(_ id: UUID) async -> Post? {
        if let known = (samplePosts + allPosts).first(where: { $0.id == id }) { return known }
        let rows: [PostRow]? = try? await supabase
            .from("posts_feed")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return rows?.first?.toPost()
    }

    // Opens someone's profile from any screen. Your own profile is the Profile tab.
    func openProfile(_ target: ProfileTarget) {
        if let id = target.userId, id == userId {
            viewedProfile = nil
            selectedTab = .profile
            return
        }
        viewedProfile = target
    }

    func fetchPublicProfile(_ id: UUID) async -> PublicProfile? {
        let rows: [PublicProfile]? = try? await supabase
            .from("public_profiles")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return rows?.first
    }

    func fetchPosts(by authorId: UUID) async -> [Post] {
        do {
            let rows: [PostRow] = try await supabase
                .from("posts_feed")
                .select()
                .eq("author_id", value: authorId)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            return rows.map { $0.toPost() }
        } catch {
            print("fetchPosts:", error)
            return []
        }
    }

    func saveProfile(fullName: String, department: String, yearLevel: String, birthday: String) async throws {
        let id = try await supabase.auth.session.user.id
        let update = ProfileUpdate(fullName: fullName, department: department,
                                   yearLevel: yearLevel, birthday: birthday)
        try await supabase
            .from("profiles")
            .update(update)
            .eq("id", value: id)
            .execute()
        try await loadProfile()
        await loadPosts()
    }

    func uploadAvatar(_ data: Data) async throws {
        let id = try await supabase.auth.session.user.id
        let path = "\(id.uuidString.lowercased())/avatar.jpg"
        try await supabase.storage
            .from("avatars")
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        let publicURL = try supabase.storage.from("avatars").getPublicURL(path: path)
        let versioned = publicURL.absoluteString + "?v=\(Int(Date().timeIntervalSince1970))"
        try await supabase
            .from("profiles")
            .update(["avatar_url": versioned])
            .eq("id", value: id)
            .execute()
        account.avatarURL = versioned
        await loadPosts()
    }

    // MARK: - Posts
    func loadPosts() async {
        do {
            let rows: [PostRow] = try await supabase
                .from("posts_feed")
                .select()
                .order("created_at", ascending: false)
                .limit(100)
                .execute()
                .value
            allPosts = rows.map { $0.toPost() }
        } catch {
            print("loadPosts:", error)
        }
    }

    func createPost(body: String, audience: PostAudience, organizationName: String,
                    allowsComments: Bool, imageData: Data?) async throws {
        let id = try await supabase.auth.session.user.id
        var imageURL: String? = nil
        if let imageData {
            let path = "\(id.uuidString.lowercased())/\(UUID().uuidString.lowercased()).jpg"
            try await supabase.storage
                .from("post-images")
                .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            imageURL = try supabase.storage.from("post-images").getPublicURL(path: path).absoluteString
        }
        let insert = PostInsert(body: body, audience: audience.rawValue,
                                organizationName: organizationName,
                                allowsComments: allowsComments, imageUrl: imageURL)
        try await supabase.from("posts").insert(insert).execute()
        await loadPosts()
    }

    func deletePost(_ post: Post) async {
        allPosts.removeAll { $0.id == post.id }
        _ = try? await supabase.from("posts").delete().eq("id", value: post.id).execute()
    }

    func hidePost(_ post: Post) {
        hiddenPostIds.insert(post.id)
    }

    // value: 1 = upvote, -1 = downvote. Tapping the same arrow again removes the vote.
    func vote(on post: Post, value: Int) {
        if let key = post.sampleKey {
            voteOnSample(key: key, value: value)
            return
        }
        guard let index = allPosts.firstIndex(where: { $0.id == post.id }) else { return }
        let old = allPosts[index].myVote
        let new = (old == value) ? 0 : value
        allPosts[index].likeCount += new - old
        allPosts[index].myVote = new

        Task {
            do {
                if new == 0 {
                    try await supabase.from("post_votes").delete().eq("post_id", value: post.id).execute()
                } else {
                    try await supabase.from("post_votes")
                        .upsert(VoteUpsert(postId: post.id, value: new), onConflict: "post_id,user_id")
                        .execute()
                }
            } catch {
                print("vote:", error)
                await loadPosts()
            }
        }
    }

    func loadComments(for postId: UUID) async -> [Comment] {
        if let key = sampleKey(for: postId) {
            return (sampleComments[key] ?? []).map {
                Comment(id: $0.id, authorName: $0.author, avatarURL: $0.avatar, body: $0.body, timeAgo: $0.date.shortAgo)
            }
        }
        do {
            let rows: [CommentRow] = try await supabase
                .from("comments_feed")
                .select()
                .eq("post_id", value: postId)
                .order("created_at", ascending: true)
                .execute()
                .value
            return rows.map { $0.toComment() }
        } catch {
            print("loadComments:", error)
            return []
        }
    }

    func addComment(to postId: UUID, body: String) async throws {
        if let key = sampleKey(for: postId) {
            let comment = StoredSampleComment(id: UUID(), author: account.fullName, avatar: account.avatarURL,
                                              body: body, date: Date())
            sampleComments[key, default: []].append(comment)
            saveSampleComments()
            if let index = samplePosts.firstIndex(where: { $0.sampleKey == key }) {
                samplePosts[index].commentCount += 1
            }
            return
        }
        try await supabase.from("comments").insert(CommentInsert(postId: postId, body: body)).execute()
        if let index = allPosts.firstIndex(where: { $0.id == postId }) {
            allPosts[index].commentCount += 1
        }
    }

    // MARK: - Messaging
    func loadConversations() async {
        do {
            let rows: [ConversationRow] = try await supabase.rpc("my_conversations").execute().value
            conversations = rows.map { $0.toConversation() }
        } catch {
            print("loadConversations:", error)
        }
    }

    func loadPeople() async -> [PublicProfile] {
        do {
            let rows: [PublicProfile] = try await supabase
                .from("public_profiles")
                .select()
                .order("full_name", ascending: true)
                .limit(300)
                .execute()
                .value
            return rows.filter { $0.id != userId }
        } catch {
            print("loadPeople:", error)
            return []
        }
    }

    // Finds the existing 1-to-1 chat with this person, or creates it
    func startChat(with personId: UUID) async throws -> UUID {
        let conversationId: UUID = try await supabase
            .rpc("get_or_create_dm", params: ["other": personId.uuidString])
            .execute()
            .value
        await loadConversations()
        return conversationId
    }

    func openConversation(_ id: UUID) async {
        activeConversationId = id
        do {
            let rows: [MessageRow] = try await supabase
                .from("messages")
                .select()
                .eq("conversation_id", value: id)
                .order("created_at", ascending: true)
                .limit(300)
                .execute()
                .value
            activeMessages = rows.map { $0.toChatMessage(me: userId) }
            await markRead(id)
        } catch {
            print("openConversation:", error)
        }
    }

    func closeConversation() {
        activeConversationId = nil
        activeMessages = []
    }

    func sendMessage(_ text: String) async throws {
        guard let conversationId = activeConversationId else { return }
        let row: MessageRow = try await supabase
            .from("messages")
            .insert(MessageInsert(conversationId: conversationId, body: text))
            .select()
            .single()
            .execute()
            .value
        appendIfNew(row)
        await loadConversations()
    }

    private func markRead(_ conversationId: UUID) async {
        _ = try? await supabase
            .rpc("mark_conversation_read", params: ["cid": conversationId.uuidString])
            .execute()
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].unreadCount = 0
        }
    }

    private func appendIfNew(_ row: MessageRow) {
        guard row.conversationId == activeConversationId,
              !activeMessages.contains(where: { $0.id == row.id }) else { return }
        activeMessages.append(row.toChatMessage(me: userId))
    }

    // MARK: - Notifications
    func loadNotifications() async {
        do {
            let rows: [NotificationRow] = try await supabase
                .from("notifications")
                .select()
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            notifications = rows.map { $0.toItem() }
        } catch {
            print("loadNotifications:", error)
        }
    }

    func markNotificationsRead() async {
        guard unreadNotifications > 0 else { return }
        for index in notifications.indices { notifications[index].isRead = true }
        _ = try? await supabase
            .from("notifications")
            .update(["is_read": true])
            .eq("is_read", value: false)
            .execute()
    }

    // MARK: - Realtime
    func startRealtime() async {
        await stopRealtime()
        guard let uid = userId?.uuidString.lowercased() else { return }

        let channel = supabase.channel("unicom-\(uid)")
        let messageInserts = channel.postgresChange(InsertAction.self, schema: "public", table: "messages")
        let postInserts = channel.postgresChange(InsertAction.self, schema: "public", table: "posts")
        let notificationInserts = channel.postgresChange(
            InsertAction.self, schema: "public", table: "notifications",
            filter: "user_id=eq.\(uid)"
        )

        do {
            try await channel.subscribeWithError()
        } catch {
            print("realtime:", error)
            return
        }
        realtimeChannel = channel

        realtimeTasks = [
            Task { [weak self] in
                for await insert in messageInserts { self?.handleNewMessage(insert) }
            },
            Task { [weak self] in
                for await _ in postInserts { await self?.loadPosts() }
            },
            Task { [weak self] in
                for await insert in notificationInserts { self?.handleNewNotification(insert) }
            }
        ]
    }

    func stopRealtime() async {
        realtimeTasks.forEach { $0.cancel() }
        realtimeTasks = []
        if let channel = realtimeChannel {
            await channel.unsubscribe()
        }
        realtimeChannel = nil
    }

    private func handleNewMessage(_ insert: InsertAction) {
        guard let row = try? insert.decodeRecord(as: MessageRow.self, decoder: JSONDecoder()) else { return }
        let fromMe = row.senderId == userId

        if row.conversationId == activeConversationId {
            appendIfNew(row)
            if !fromMe { Task { await markRead(row.conversationId) } }
        }

        Task {
            await loadConversations()
            if !fromMe && row.conversationId != activeConversationId {
                let sender = conversations.first { $0.id == row.conversationId }?.name ?? "New message"
                LocalNotifier.shared.show(title: sender, body: row.body, kind: "message",
                                          conversationId: row.conversationId)
            }
        }
    }

    private func handleNewNotification(_ insert: InsertAction) {
        guard let row = try? insert.decodeRecord(as: NotificationRow.self, decoder: JSONDecoder()) else { return }
        notifications.insert(row.toItem(), at: 0)
        LocalNotifier.shared.show(title: row.title, body: row.subtitle, kind: row.kind, postId: row.postId)
    }
}
