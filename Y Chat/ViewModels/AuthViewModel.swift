//
//  AuthViewModel.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var currentUserId: String?
    @Published var currentUser: ChatUser?
    
    private var cancellables = Set<AnyCancellable>()
    var authRepository: AuthRepository?
    
    init() {}
    
    func setupAuthListener() {
        authRepository?.authStateListener()
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.isAuthenticated = user.uid.count > 0 ? true : false
                self?.currentUserId = user.uid
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    func login(email: String, password: String) {
        isLoading = true
        authRepository?.signIn(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                case .finished:
                    break
                }
            } receiveValue: { [weak self] chatUser in
                self?.currentUser = chatUser
                self?.currentUserId = chatUser.uid
            }
            .store(in: &cancellables)
    }
    
    func signUp(email: String, password: String, username: String) {
        isLoading = true
        authRepository?.signUp(email: email, password: password, username: username)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                case .finished:
                    break
                }
            } receiveValue: { [weak self] chatUser in
                self?.currentUser = chatUser
                self?.currentUserId = chatUser.uid
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        authRepository?.signOut()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                case .finished:
                    self?.currentUserId = nil
                    self?.currentUser = nil
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
