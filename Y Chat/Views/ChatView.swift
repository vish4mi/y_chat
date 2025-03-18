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
    @EnvironmentObject var appDependencies: AppDependencies
    @StateObject var authViewModel: AuthViewModel // Consider removing if possible
    @StateObject private var chatViewModel: ChatViewModel
    @State private var messageText = ""
    @State private var showingGroupDetails = false
    @State private var newMemberSearch = ""
    @State private var isFilePickerPresented = false
    @State private var selectedFileURL: URL?
    
    let conversationId: String
    
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
    init(conversationId: String, authViewModel: AuthViewModel) {
        self.conversationId = conversationId
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(
            conversationId: conversationId,
            currentUserId: authViewModel.currentUserId ?? "",
            authViewModel: authViewModel
        ))
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
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingGroupDetails) {
            if let conversation = chatViewModel.conversation {
                GroupDetailsView(conversation: conversation)
            }
        }
        .onAppear(perform: setupChat)
        .onDisappear(perform: chatViewModel.removeListeners)
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
            Button(action: {
                isFilePickerPresented = true
            }) {
                Image(systemName: "paperclip") // Use a paperclip icon
                    .font(.system(size: 20))
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [.image, .movie, .audio],
                allowsMultipleSelection: false
            ) { result in
                handleFilePickerResult(result)
            }
            
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: messageText) { _ in
                    chatViewModel.handleTyping(isTyping: !messageText.isEmpty, conversationId: conversationId)
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
    
    // Handle file picker result
    private func handleFilePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let fileURLs):
            if let fileURL = fileURLs.first {
                selectedFileURL = fileURL
                chatViewModel.uploadMedia(fileURL: fileURL)
            }
        case .failure(let error):
            print("File picker error: \(error.localizedDescription)")
        }
    }
    // MARK: - Methods
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatViewModel.sendMessage(messageText)
        messageText = ""
        chatViewModel.handleTyping(isTyping: false, conversationId: conversationId)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard !chatViewModel.messages.isEmpty else { return }
        withAnimation {
            proxy.scrollTo(chatViewModel.messages.last?.id, anchor: .bottom)
        }
    }
    
    private func setupChat() {
        chatViewModel.chatRepository = appDependencies.chatRepository
        chatViewModel.listenForMessages()
        chatViewModel.fetchConversation()
        chatViewModel.fetchMessages()
        chatViewModel.observeTyping()
    }
}
