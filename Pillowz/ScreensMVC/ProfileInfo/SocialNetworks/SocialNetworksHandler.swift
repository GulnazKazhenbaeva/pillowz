//
//  SocialNetworksHandler.swift
//  Pillowz
//
//  Created by Samat on 04.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyVK
import SwiftyJSON
import FacebookCore
import FacebookLogin
import GoogleSignIn

protocol SocialNetworksHandlerDelegate {
    func didPickToken(_ token:String, fromSocialNetwork socialNetwork:SocialNetworkLinks)
}

class SocialNetworksHandler: NSObject, SwiftyVKDelegate, GIDSignInDelegate, GIDSignInUIDelegate, InstagramWebViewDelegate {
    var delegate:SocialNetworksHandlerDelegate?
    let VK_APP_ID:String = "6288855"
    let scopes: Scopes = [.friends]

    override init() {
        super.init()
        
        VK.setUp(appId: VK_APP_ID, delegate: self)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func getTokenForSocialNetwork(_ socialNetwork:SocialNetworkLinks) {
        if (socialNetwork == .vkontakte) {
            authorizeWithVK()
        } else if (socialNetwork == .instagram) {
            authorizeWithInstagram()
        } else if (socialNetwork == .google) {
            authorizeWithGoogle()
        } else if (socialNetwork == .facebook) {
            authorizeWithFacebook()
        }
    }
    
    //VKONTAKTE
    func authorizeWithVK() {
        if (VK.sessions.default.state != .authorized) {
            VK.sessions.default.logIn(
                onSuccess: { info in
                    self.delegate?.didPickToken(info["access_token"]!, fromSocialNetwork: .vkontakte)
            },
                onError: { error in

            }
            )
        } else {
            VK.sessions.default.logOut()
            
            authorizeWithVK()
        }
        
    }
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        // Called when SwiftyVK attempts to get access to user account
        // Should return a set of permission scopes
        return scopes
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        // Called when SwiftyVK wants to present UI (e.g. webView or captcha)
        // Should display given view controller from current top view controller
        //let vc = delegate as! UIViewController
        ProfileTabViewController.shared.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        // Called when user grants access and SwiftyVK gets new session token
        // Can be used to run SwiftyVK requests and save session data
        self.delegate?.didPickToken(info["access_token"]!, fromSocialNetwork: .vkontakte)
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        // Called when existing session token has expired and successfully refreshed
        // You don't need to do anything special here
    }
    
    func vkTokenRemoved(for sessionId: String) {
        // Called when user was logged out
        // Use this method to cancel all SwiftyVK requests and remove session data
    }

    
    
    
    
    //FACEBOOK
    func authorizeWithFacebook() {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile], viewController: (self.delegate as! UIViewController)) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
                
                
            case .success(grantedPermissions: let grantedPermissions, declinedPermissions: let declinedPermissions, token: let accessToken):
                self.delegate?.didPickToken(accessToken.authenticationToken, fromSocialNetwork: .facebook)
                break
                
            }
        }
    }
    
    func fetchProfileData(){
        let params = ["fields": "email, first_name, last_name"]
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: params).start { (connection, result, error) in
            if let error = error {

                print(error)
                return
            }
            
            guard let userData = result as? [String: Any] else {

                return
            }
            
            if let email = userData["email"] as? String {
                print(email)
            }
            
            print(userData)
        }
        
    }
        
    // GOOGLE
    func authorizeWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            let idToken = user.authentication.accessToken
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            // ...
            
            self.delegate?.didPickToken(idToken!, fromSocialNetwork: .google)
        } else {
            print("\(error.localizedDescription)")
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        ProfileTabViewController.shared.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        (self.delegate as! UIViewController).dismiss(animated: true, completion: nil)
    }

    //INSTAGRAM
    func authorizeWithInstagram() {
        let instagramViewController = InstagramWebViewController()
        let instagramNavController = UINavigationController(rootViewController: instagramViewController)
        instagramViewController.delegate = self
        ProfileTabViewController.shared.navigationController?.present(instagramNavController, animated: true, completion: nil)
    }

    func didPickInstagramToken(_ token: String) {
        self.delegate?.didPickToken(token, fromSocialNetwork: .instagram)
    }
    
    static func getSocialNetworkName(_ socialNetwork: SocialNetworkLinks) -> String {
        switch socialNetwork {
        case .facebook:
            return "facebook"
        case .google:
            return "google"
        case .instagram:
            return "instagram"
        case .vkontakte:
            return "vk"
        }
    }
}
