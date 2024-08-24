//
//  ViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import SVProgressHUD

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet private var continueWithApple: ASAuthorizationAppleIDButton!
    
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.continueWithApple.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if BeamNetworking.shared.sharedUser?.onboardingComplete == true {
            self.continueToDashboard()
        }
    }

    @objc private func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    SVProgressHUD.show(withStatus: error.localizedDescription)
                    return
                } else {
                    //TODO: Create a univeral shared User here after sign in.
                    
                    // Create a user if there isn't one, if there is one load the user.
                    guard let user = authResult?.user, let email = user.email else { return }
                    BeamNetworking.shared.getUser(userId: user.uid) { userFound in
                        if userFound {
                            if BeamNetworking.shared.sharedUser?.onboardingComplete == true {
                                self.continueToDashboard()
                            } else {
                                self.continueToOnboarding()
                            }
                        } else {
                            BeamNetworking.shared.createUser(userId: user.uid, email: email) { userCreated in
                                if userCreated {
                                    self.continueToOnboarding()
                                } else {
                                    SVProgressHUD.show(withStatus: "There was an error creating your account, please wait a few moments and sign in again.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func continueToDashboard() {
        guard let dashboardNavController = self.storyboard?.instantiateViewController(withIdentifier: "MainDashboardNav") else { return }
        self.navigationController?.present(dashboardNavController, animated: true)
    }
    
    private func continueToOnboarding() {
        let onboardingController = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.navigationController?.pushViewController(onboardingController, animated: true)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                    
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                  return
                }

                if random < charset.count {
                  result.append(charset[Int(random)])
                  remainingLength -= 1
                }
            }
        }

        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

