//
//  ConversationView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct ConversationView: View {
    var conversation: Conversation
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var draft = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                    // Tapping the person at the top opens their profile.
                    Button {
                        appState.openProfile(ProfileTarget(conversation: conversation))
                    } label: {
                        HStack(spacing: 12) {
                            if conversation.isGroup {
                                Image(systemName: "person.3.fill")
                                    .foregroundStyle(.white.opacity(0.7))
                                    .frame(width: 36, height: 36)
                                    .background(.white.opacity(0.1), in: Circle())
                            } else {
                                AvatarView(url: conversation.avatarURL, size: 36)
                            }
                            Text(conversation.name)
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(conversation.isGroup || conversation.otherUserId == nil)
                    Spacer()
                }
                .padding()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(appState.activeMessages) { message in
                                HStack {
                                    if message.isSentByMe { Spacer() }

                                    VStack(alignment: message.isSentByMe ? .trailing : .leading, spacing: 4) {
                                        Text(message.text)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundStyle(.white)
                                            .padding(10)
                                            .background(message.isSentByMe ? Color.appRed : Color.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                                        Text(message.timestamp)
                                            .font(.system(.caption2, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                    .frame(maxWidth: 260, alignment: message.isSentByMe ? .trailing : .leading)

                                    if !message.isSentByMe { Spacer() }
                                }
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: appState.activeMessages.count) {
                        scrollToBottom(proxy)
                    }
                    .onAppear {
                        scrollToBottom(proxy)
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.appPink)
                }

                HStack(spacing: 10) {
                    TextField("Type a message...", text: $draft)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassCapsule()
                        .submitLabel(.send)
                        .onSubmit(send)

                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.appRed, in: Circle())
                    }
                }
                .padding()
            }
        }
        .toolbar(.hidden)
        .task {
            await appState.openConversation(conversation.id)
        }
        .onDisappear {
            appState.closeConversation()
            Task { await appState.loadConversations() }
        }
    }

    func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let last = appState.activeMessages.last {
            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
        }
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        Task {
            do {
                try await appState.sendMessage(text)
                errorMessage = nil
            } catch {
                draft = text
                errorMessage = "Message failed to send."
            }
        }
    }
}

#Preview {
    ConversationView(conversation: Conversation(name: "Preview"))
        .environmentObject(AppState())
}
