//
//  NewChatView.swift
//  UNICOM
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct NewChatView: View {
    var onOpen: (UUID) -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var people: [PublicProfile] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var filteredPeople: [PublicProfile] {
        if searchText.isEmpty { return people }
        return people.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("New Message")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white.opacity(0.6))
                    TextField("Search people...", text: $searchText)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .glassCapsule()
                .padding(.horizontal)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.appPink)
                        .padding(.horizontal)
                }

                ScrollView {
                    VStack(spacing: 10) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else if filteredPeople.isEmpty {
                            Text("No people found.")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }

                        ForEach(filteredPeople) { person in
                            Button {
                                open(person)
                            } label: {
                                HStack(spacing: 12) {
                                    AvatarView(url: person.avatarUrl, size: 44)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(person.fullName)
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.semibold)
                                        Text(person.yearLevel.isEmpty ? person.role : person.yearLevel)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    .foregroundStyle(.white)
                                    Spacer()
                                }
                                .padding()
                                .glassCard(cornerRadius: 16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            people = await appState.loadPeople()
            isLoading = false
        }
    }

    func open(_ person: PublicProfile) {
        Task {
            do {
                let conversationId = try await appState.startChat(with: person.id)
                onOpen(conversationId)
            } catch {
                errorMessage = "Couldn't start the chat."
            }
        }
    }
}
