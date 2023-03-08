//
//  SignInVC.swift
//  MediaFinder11
//
//  Created by mohamed saad on 10/12/2022.
//

import UIKit
import CryptoKit

class SignInVC: UIViewController {
    //MARK: - Outlets.
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //MARK: - Propreties.
    private var savedEmail = ""
    private var savedPassword :  Int64?
    //MARK: - Life Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        receiveData()
        self.title = "Sign In"
        UserDefaults.standard.set(true, forKey: "isSignedUp")
        UserDefaults.standard.set(false, forKey: "isSignedIn")
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    //MARK: - Actions.
    @IBAction func signInBtnTapped(_ sender: UIButton) {
        signInButTappedAction()
    }
    @IBAction func signUpBtn(_ sender: UIButton) {
        let signUpVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
}
//MARK: - receiveData
extension SignInVC {
    public func receiveData() -> (String, String)? {
        do {
            let user = try SQLiteManager.shared().db!.pluck(SQLiteManager.usersTable)

            if let email = user?[SQLiteManager.email], let password = user?[SQLiteManager.password] {
                return (email, password)
            }
        } catch {
            print("Cannot read data from table")
        }
        return nil
    }
    private func hashPassword(_ password: String) -> String {
        let passwordData = Data(password.utf8)
        let hashed = SHA256.hash(data: passwordData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
//MARK: - private Methods.
extension SignInVC{
    private func goToMediaListVC(){
        let mediaListVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MediaListVC") as! MediaListVC
        self.navigationController?.pushViewController(mediaListVC, animated: true)
    }
    private func isEnteredData ()-> Bool {
            guard let enteredEmail = emailTextField.text, enteredEmail != "",
                  let enteredPassword = passwordTextField.text, enteredPassword != "" else{
                return false
            }
            return true
        }
        
    private func isCorrectUser() -> Bool {
        guard isEnteredData(),
              let (savedEmail, savedPassword) = receiveData(),
              let enteredEmail = emailTextField.text,
              let enteredPassword = passwordTextField.text else {
            return false
        }
        
        let hashedEnteredPassword = hashPassword(enteredPassword)
        return savedEmail == enteredEmail && savedPassword == hashedEnteredPassword
    }
    private func signInButTappedAction() {
        if isEnteredData() {
            guard let email = emailTextField.text, let password = passwordTextField.text else {
                return
            }
            if isCorrectUser() {
                goToMediaListVC()
                TestEmail()
            } else {
                showAlert(title: "Sorry", message: "Email or Password are wrong")
                TestEmail()
            }
        } else {
            showAlert(title: "Sorry", message: "All Data is required")
            TestEmail()
        }
    }

    func TestEmail() {
        if let savedEmail = receiveData()?.0, let savedPassword = receiveData()?.1 {
            print(savedEmail)
            print(savedPassword)
        }
    }
}

