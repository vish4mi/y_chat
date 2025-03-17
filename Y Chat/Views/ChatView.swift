//
//  ChatView.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var messageText = ""
    @StateObject var chatViewModel: ChatViewModel
    let conversationId: String
    @State private var showingGroupDetails = false
    @State private var newMemberSearch = ""
    
    // Computed properties
    private var navigationTitle: String {
        if chatViewModel.conversation?.isGroup == true {
            return chatViewModel.conversation?.groupName ?? "Group Chat"
        }
        return chatViewModel.conversation?.otherParticipantUsername ?? "Chat"
    }
    
    private var shouldShowGroupHeader: Bool {
        chatViewModel.conversation?.isGroup == true
    }
    
    // Initialization
    init(conversationId: String) {
        self.conversationId = conversationId
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        self._chatViewModel = StateObject(
            wrappedValue: ChatViewModel(
                conversationId: conversationId,
                currentUserId: currentUserId
            )
        )
    }
    
    var body: some View {
        VStack {
            // Group header
            if shouldShowGroupHeader {
                groupHeader
            }
            
            // Messages list
            messagesList
            
            // Message input
            messageInput
        }
        .navigationTitle(navigationTitle)
        .environmentObject(authViewModel)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingGroupDetails) {
            if let conversation = chatViewModel.conversation {
                GroupDetailsView(conversation: conversation)
            }
        }
        .onAppear(perform: setupChat)
        .onDisappear(perform: chatViewModel.removeListeners)
        .onChange(of: chatViewModel.messages) { _ in
            print("*******Message Chnaged")
//            chatViewModel.sc
        }
    }
    
    // MARK: - Subviews
    
    private var groupHeader: some View {
        HStack {
            Button {
                showingGroupDetails.toggle()
            } label: {
                HStack {
                    Text("Members")
                    Image(systemName: "chevron.down")
                }
            }
            Spacer()
            
            if chatViewModel.isTyping && !chatViewModel.typingUserNames.isEmpty {
                GroupTypingIndicator(names: chatViewModel.typingUserNames)
            }
        }
        .padding()
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.senderId == authViewModel.currentUserId,
                            showSenderName: chatViewModel.conversation?.isGroup == true
                        )
                        .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: chatViewModel.messages) { _ in
                chatViewModel.messages.sort {
                    $0.timestamp ?? Date.distantFuture < $1.timestamp ?? Date.distantFuture
                }
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private var messageInput: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: messageText) { _ in
                    chatViewModel.handleTyping(isTyping: !messageText.isEmpty)
                }
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(navigationTitle)
                if chatViewModel.isTyping {
                    Text(typingStatusText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var typingStatusText: String {
        guard let conversation = chatViewModel.conversation else { return "" }
        
        if conversation.isGroup {
            let typingCount = chatViewModel.typingUserNames.count
            
            // Handle no users typing
            if typingCount == 0 {
                return ""
            }
            
            // Handle single user typing
            if typingCount == 1 {
                let name = chatViewModel.typingUserNames.first ?? "Someone"
                return "\(name) is typing..."
            }
            
            // Handle multiple users typing
            let names = chatViewModel.typingUserNames.prefix(2).joined(separator: ", ")
            let suffix = typingCount > 2 ? " and others" : ""
            return "\(names)\(suffix) are typing..."
        }
        
        // Handle 1:1 chat
        return "typing..."
    }
    
    // MARK: - Methods
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatViewModel.sendMessage(messageText)
        messageText = ""
        chatViewModel.handleTyping(isTyping: false)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard !chatViewModel.messages.isEmpty else { return }
        withAnimation {
            proxy.scrollTo(chatViewModel.messages.last?.id, anchor: .bottom)
        }
    }
    
    private func setupChat() {
        chatViewModel.listenForMessages()
        chatViewModel.fetchMessages(conversationId: conversationId)
        chatViewModel.observeTyping()
    }
}
