//
//  AppleSignInManager.swift
//

import UIKit
import AuthenticationServices

protocol AppleSignInManagerDelegate {
    func didFailedLogin(error: String)
    func didSuccessLogin(userId: String, firstName: String, lastName: String, email : String)
}

class AppleSignInManager : NSObject {
    static var shared = AppleSignInManager()
    var delegate : AppleSignInManagerDelegate?
    
    func setupAppleSignInButton(viewController: UIViewController, stackView: UIStackView) {
        if #available(iOS 13.0, *) {
            // Set button style based on device theme
            let isDarkTheme = viewController.view.traitCollection.userInterfaceStyle == .dark
            let style: ASAuthorizationAppleIDButton.Style = isDarkTheme ? .white : .black
            
            // Create and Setup Apple ID Authorization Button
            let btnAppleSignIn = ASAuthorizationAppleIDButton(type: .default, style: style)
            //btnAppleSignIn.cornerRadius = 10
            btnAppleSignIn.addTarget(self, action: #selector(onClickAppleSignIn), for: .touchUpInside)
            
            // Add Height Constraint
            let heightConstraint = btnAppleSignIn.heightAnchor.constraint(equalToConstant: 35)
            btnAppleSignIn.addConstraint(heightConstraint)
            
            //Add apple sign in button
            stackView.addArrangedSubview(btnAppleSignIn)
        } else {
            // Fallback on earlier versions
            print("Not supported sign in with apple")
        }
        
    }
    
    @objc func onClickAppleSignIn() {
        print("Apple Sign In")
        if #available(iOS 13.0, *) {
            let appleIdProvider = ASAuthorizationAppleIDProvider()
            
            let request = appleIdProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationVC = ASAuthorizationController(authorizationRequests: [request])
            
            authorizationVC.delegate = self
            
            authorizationVC.performRequests()
        } else {
            // Fallback on earlier versions
            print("Not supported sign in with apple")
        }
    }
}


extension AppleSignInManager : ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleCredintialId = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let email = appleCredintialId.email ?? ""
            let userId = appleCredintialId.user
            let firstName = appleCredintialId.fullName?.givenName ?? ""
            let lastName = appleCredintialId.fullName?.familyName ?? ""
            
            if self.delegate != nil {
                self.delegate?.didSuccessLogin(userId: userId, firstName: firstName, lastName: lastName, email: email)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Auth error : \(error.localizedDescription)")
        if self.delegate != nil {
            self.delegate?.didFailedLogin(error: error.localizedDescription)
        }
    }
}
