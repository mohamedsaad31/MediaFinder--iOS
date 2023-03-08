//
//  AppDelegate.swift
//  MediaFinder11
//
//  Created by mohamed saad on 03/12/2022.
//

import UIKit
import IQKeyboardManagerSwift
import SQLite

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    //MARK: - Properties.
    var window: UIWindow?
    static var db: Connection!
    
    //MARK: - Application Methods.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        let _ = SQLiteManager.shared()
        handleRoot()
        return true
    }
    //MARK: - Public Methods.
    public func switchToSignInScreen(){
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInVC")
        let navController = UINavigationController(rootViewController: signInVC)
        window?.rootViewController = navController
    }
    private func switchToMediaListVC(){
        let mediaListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MediaListVC")
        let navController = UINavigationController(rootViewController: mediaListVC)
        window?.rootViewController = navController
    }
    func switchToProfileVC(){
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")
        let navController = UINavigationController(rootViewController: profileVC)
        window?.rootViewController = navController
    }
    func switchToSignUpVC(){
        let signUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC")
        let navController = UINavigationController(rootViewController: signUpVC)
        window?.rootViewController = navController
    }
    // MARK: - Handle Root
    public func handleRoot() {
        let isSignedUp = UserDefaults.standard.bool(forKey: "isSignedUp")
        let isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
        
        if isSignedUp {
            if isSignedIn {
                switchToMediaListVC()
            } else {
                switchToSignInScreen()
            }
        } else {
            switchToSignUpVC()
        }
    }
}
