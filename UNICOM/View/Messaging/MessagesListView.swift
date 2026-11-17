//
//  MessagesListView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var showNewChat = false
    @State private var openedConversation: Conversation? = nil

    var filteredConversations: [Conversation] {
        if searchText.isEmpty { return appState.conversations }
        return appState.conversations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // A tapped message banner asks for a conversation; open it once we have the list.
    private func openPendingConversation() {
        guard let id = appState.pendingConversationId else { return }
        if let conversation = appState.conversations.first(where: { $0.id == id }) {
            openedConversation = conversation
            appState.pendingConversationId = nil
        } else {
            Task {
                await appState.loadConversations()
                openedConversation = appState.conversations.first { $0.id == id }
                appState.pendingConversationId = nil
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Messages")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            showNewChat = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                        }
                        .glassCard(cornerRadius: 12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.6))
                        TextField("Search people, group...", text: $searchText)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .glassCapsule()
                    .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 12) {
                            if filteredConversations.isEmpty {
                                Text("No conversations yet.\nTap the pencil to start one.")
                                    .font(.system(.footnote, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.top, 40)
                            }

                            ForEach(filteredConversations) { conversation in
                                NavigationLink(value: conversation) {
                                    HStack(spacing: 12) {
                                        if conversation.isGroup {
                                            Image(systemName: "person.3.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(.white.opacity(0.7))
                                                .frame(width: 48, height: 48)
                                                .background(.white.opacity(0.1), in: Circle())
                                        } else {
                                            AvatarView(url: conversation.avatarURL, size: 48)
                                        }

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(conversation.name)
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.semibold)
                                            Text(conversation.lastMessage.isEmpty ? "Say hi 👋" : conversation.lastMessage)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.6))
                                                .lineLimit(1)
                                        }
                                        .foregroundStyle(.white)

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 6) {
                                            Text(conversation.timestamp)
                                                .font(.system(.caption2, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.5))
                                            if conversation.unreadCount > 0 {
                                                // Grows with the number of digits; "9+" above 9.
                                                Text(conversation.unreadCount > 9 ? "9+" : "\(conversation.unreadCount)")
                                                    .font(.system(.caption2, design: .rounded))
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 7)
                                                    .padding(.vertical, 4)
                                                    .frame(minWidth: 22)
                                                    .background(Color.appRed, in: Capsule())
                                            }
                                        }
                                    }
                                    .padding()
                                    .glassCard(cornerRadius: 16)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 90)
                    }
                    .refreshable { await appState.loadConversations() }
                }
            }
            .navigationDestination(for: Conversation.self) { conversation in
                ConversationView(conversation: conversation)
            }
            .navigationDestination(item: $openedConversation) { conversation in
                ConversationView(conversation: conversation)
            }
            .sheet(isPresented: $showNewChat) {
                NewChatView { conversationId in
                    showNewChat = false
                    openedConversation = appState.conversations.first { $0.id == conversationId }
                }
            }
            .toolbar(.hidden)
            .task {
                await appState.loadConversations()
                openPendingConversation()
            }
            .onChange(of: appState.pendingConversationId) { _, _ in
                openPendingConversation()
            }
        }
    }
}

#Preview {
    MessagesListView()
        .environmentObject(AppState())
}

