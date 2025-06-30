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
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailErrorMessage: String?
    @State private var showPassword: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToSignUp: Bool = false
    @State private var showInlineSignUp: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    private var isSignInButtonEnabled: Bool {
        return emailErrorMessage == nil && !authViewModel.password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Log in")
                    .font(Typography.largeTitle)
                    .foregroundColor(.yellow)
                
                CustomTextField(icon: "envelope", placeholder: "Email", text: $authViewModel.email)
                    .font(Typography.body)
                    .focused($focusedField, equals: .email)
                    .onChange(of: focusedField) { newFocus in
                        if newFocus != .email {
                            emailErrorMessage = ValidationHelper.validateEmail(authViewModel.email)
                        } else {
                            emailErrorMessage = nil
                        }
                    }
                
                if let emailErrorMessage = emailErrorMessage {
                    Text(emailErrorMessage)
                        .font(Typography.subheadline)
                        .foregroundColor(.red)
                }
                
                CustomSecureField(icon: "lock", placeholder: "Password", text: $authViewModel.password, isSecure: !showPassword, toggle: { showPassword.toggle() })
                    .font(Typography.body)
                    .focused($focusedField, equals: .password)
                
                if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .font(Typography.subheadline)
                            .foregroundColor(.red)
                            .padding(.bottom, 5)
                        
                        if showInlineSignUp {
                            HStack {
                                Button("New User? Sign Up") {
                                    navigateToSignUp = true
                                }
                                .font(Typography.body)
                                .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .font(Typography.body)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Button {
                    Task {
                        do {
                            try await authViewModel.signIn()
                            errorMessage = nil
                            await userProfileViewModel.loadCurrentUser()
                            dismiss()
                        } catch let error as NSError {
                            handleSignInError(error)
                        }
                    }
                } label: {
                    Text("Sign In")
                        .font(Typography.headline)
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
                        .font(Typography.subheadline)
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
                                try await authViewModel.signInGoogle()
                                await userProfileViewModel.loadCurrentUser()
                                dismiss()
                            } catch {
                                print("Google Sign-In Error: \(error)")
                                errorMessage = "Failed to sign in with Google. Please try again."
                                showInlineSignUp = false
                            }
                        }
                    }
                    .frame(height: 55)
                    
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black) { request in
                        let nonce = AuthenticationViewModel.SignInWithAppleHelper.randomNonceString()
                        authViewModel.currentNonce = nonce
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = AuthenticationViewModel.SignInWithAppleHelper.sha256(nonce)
                    } onCompletion: { result in
                        Task {
                            do {
                                guard let nonce = authViewModel.currentNonce else {
                                    throw NSError(domain: "NonceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nonce not set."])
                                }
                                try await authViewModel.signInWithApple(result: result, nonce: nonce)
                                await userProfileViewModel.loadCurrentUser()
                                dismiss()
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
                    .font(Typography.body)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Log in")
                        .font(Typography.title)
                        .foregroundColor(.primary)
                }
            }
            .background(
                NavigationLink(destination: SignUpView().environmentObject(authViewModel), isActive: $navigateToSignUp) {
                    EmptyView()
                }
            )
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: $authViewModel.email, onDismiss: { showForgotPassword = false })
            }
            .onAppear {
                if authViewModel.isAuthenticated {
                    print("UserAuthenticationView: User already authenticated, dismissing")
                    dismiss()
                }
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
    UserAuthenticationView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
        .environmentObject(CartManager())
}

