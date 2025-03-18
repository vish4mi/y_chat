//
//  ConversationsListView.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import SwiftUI
import FirebaseFirestore

struct ConversationsListView: View {
    @EnvironmentObject var appDependencies: AppDependencies
    @StateObject var authViewModel: AuthViewModel
    @StateObject var viewModel = ConversationsViewModel()
    @State private var isShowingGroupChatCreator = false

    @State private var showNewChat = false  // Added for new chat flow
    
    init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }
    
    var body: some View {
        List(viewModel.conversations) { conversation in
            NavigationLink {
                ChatView(
                    conversationId: conversation.id ?? "", authViewModel: authViewModel
                )
            } label: {
                ConversationRow(conversation: conversation)
            }
        }
        .navigationTitle("Chats")
        .toolbar {
            // + Button for new chat (leading side)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showNewChat = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isShowingGroupChatCreator = true
                }) {
                    Image(systemName: "person.3.fill")
                        .font(.title2)
                }
            }
            // Sign Out button (trailing side)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    authViewModel.signOut()
                }
            }
        }
        .sheet(isPresented: $showNewChat) {
            NewChatView()  // Your new chat creation view
        }
        .sheet(isPresented: $isShowingGroupChatCreator) {
            NewGroupView() // Group chat creation view
        }
        .onAppear {
            viewModel.chatRepository = appDependencies.chatRepository
            viewModel.fetchConversations()
        }
    }
}
