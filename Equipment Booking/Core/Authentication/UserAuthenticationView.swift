//
//  UserAuthenticationView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct UserAuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailErrorMessage: String?
    @Binding var showSignInView: Bool
    @State private var showPassword: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToSignUp: Bool = false
    @State private var showInlineSignUp: Bool = false
    @State private var navigateToTabsView: Bool = false
    @State private var selectedTab: String? = "search"
    @State private var navigateToSearch: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    private var isSignInButtonEnabled: Bool {
        return emailErrorMessage == nil && !viewModel.password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Log in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                    .focused($focusedField, equals: .email)
                    .onChange(of: focusedField) { newFocus in
                        if newFocus != .email {
                            emailErrorMessage = ValidationHelper.validateEmail(viewModel.email)
                        } else {
                            emailErrorMessage = nil
                        }
                    }
                
                if let emailErrorMessage = emailErrorMessage {
                    Text(emailErrorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: !showPassword, toggle: { showPassword.toggle() })
                    .focused($focusedField, equals: .password)
                
                if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.bottom, 5)
                        
                        if showInlineSignUp {
                            HStack {
                                Button("New User? Sign Up") {
                                    navigateToSignUp = true
                                }
                                .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            errorMessage = nil
                            await userProfileViewModel.loadCurrentUser()
                            navigateToTabsView = true
                        } catch let error as NSError {
                            handleSignInError(error)
                        }
                    }
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isSignInButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
                .disabled(!isSignInButtonEnabled)
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Text("or")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 8)
                
                VStack(spacing: 20) {
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                await userProfileViewModel.loadCurrentUser()
                                navigateToTabsView = true
                            } catch {
                                print("Google Sign-In Error: \(error)")
                                errorMessage = "Failed to sign in with Google. Please try again."
                                showInlineSignUp = false
                            }
                        }
                    }
                    .frame(height: 55)
                    
                    // Updated Sign In with Apple button with onRequest and onCompletion handlers
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black) { request in
                        let nonce = SignInWithAppleHelper.randomNonceString()
                        viewModel.currentNonce = nonce // Store raw nonce in viewModel
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = SignInWithAppleHelper.sha256(nonce) // Hash for Apple
                    } onCompletion: { result in
                        Task {
                            do {
                                guard let nonce = viewModel.currentNonce else {
                                    throw NSError(domain: "NonceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nonce not set."])
                                }
                                try await viewModel.signInWithApple(result: result, nonce: nonce) // Pass the stored nonce value
                                await userProfileViewModel.loadCurrentUser()
                                navigateToTabsView = true
                            } catch {
                                print("Apple Sign-In Error: \(error)")
                                errorMessage = "Failed to sign in with Apple. Please try again."
                                showInlineSignUp = false
                            }
                        }
                    }
                    .frame(height: 55)
                }
                
                if !showInlineSignUp {
                    Button("Don't have an account? Sign Up") {
                        navigateToSignUp = true
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                
                Spacer()
                
                Button(action: {
                    navigateToSearch = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.yellow)
                        Text("Explore")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.white.opacity(0.1)
                            .background(.ultraThinMaterial)
                    )
                }
                
                NavigationLink(destination: SignUpView().environmentObject(viewModel), isActive: $navigateToSignUp) {
                    EmptyView()
                }
                
                if #available(iOS 18.0, *) {
                    NavigationLink(destination: TabsView(selectedTab: $selectedTab)
                        .environmentObject(CartManager(isReadOnly: !viewModel.isAuthenticated)),
                        isActive: $navigateToTabsView) {
                        EmptyView()
                    }
                    NavigationLink(destination: TabsView(selectedTab: .constant("search"))
                        .environmentObject(CartManager(isReadOnly: true)),
                        isActive: $navigateToSearch) {
                        EmptyView()
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: $viewModel.email, onDismiss: { showForgotPassword = false })
            }
        }
    }
    
    private func handleSignInError(_ error: NSError) {
        print("Sign-in error: \(error.domain) - \(error.localizedDescription)")
        switch error.code {
        case 404:
            errorMessage = "Email not registered. Please sign up or try again."
            showInlineSignUp = true
        case 401:
            errorMessage = "Incorrect password. Please try again."
            showInlineSignUp = true
        case 400:
            errorMessage = "Invalid email format. Please check and try again."
            showInlineSignUp = false
        default:
            errorMessage = "An unexpected error occurred."
            showInlineSignUp = true
        }
    }
}

// Updated SignInWithAppleButtonViewRepresentable to handle request and completion
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void
    
    init(type: ASAuthorizationAppleIDButton.ButtonType,
         style: ASAuthorizationAppleIDButton.Style,
         onRequest: @escaping (ASAuthorizationAppleIDRequest) -> Void = { _ in },
         onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void = { _ in }) {
        self.type = type
        self.style = style
        self.onRequest = onRequest
        self.onCompletion = onCompletion
    }
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.didTapButton), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let parent: SignInWithAppleButtonViewRepresentable
        
        init(_ parent: SignInWithAppleButtonViewRepresentable) {
            self.parent = parent
        }
        
        @objc func didTapButton() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            parent.onRequest(request)
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            parent.onCompletion(.success(authorization))
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            parent.onCompletion(.failure(error))
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
    }
}

#Preview {
    UserAuthenticationView(showSignInView: .constant(true))
        .environmentObject(UserProfileViewModel())
}

