//
//  AppDelegate.swift
//  Plex
//
//  Created by RD on 2/11/21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
 
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
          
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in google \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        print("Did sign in with google: \(user)")
        
        guard let email = user.profile.email,
        let firstName = user.profile.givenName,
        let lastName = user.profile.familyName else {
            return
        }
        //checking if user already exists in database if not insert user
        DatabaseManager.shared.userExists(with: email, completion: {exists in
            if !exists{
                //insert user in database
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
            }
        })
        //grabbing auth object from user, if not print error
        guard let authentication = user.authentication else {
            print("Missing auth object from google user")
            return
        }
        //get credential by calling google auth provider, pass tokens
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("failed to log in google")
                return
            }
            print("succesfully signed in")
        })
        
    }
    //once you have credentials, use firebase auth to sign in
    
        
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
            print("Google user was disconnected")
        }
}

