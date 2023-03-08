//
//  ProfileVC.swift
//  MediaFinder11
//
//  Created by mohamed saad on 10/12/2022.
//

import UIKit

class ProfileVC: UIViewController {
    
    //MARK: - Outlets.
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    //MARK: - Life Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.retrieveData()
        setUpLeftButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
}
//MARK: - private methods
extension ProfileVC {
    private func setup(){
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        UserDefaults.standard.set(true, forKey: "isSignedUp")
        makeRounded()
        setUpLogOutButton()
       
    }
    private func makeRounded() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
        profileImageView.clipsToBounds = true
    }
    
    private func setUpLogOutButton(){
        let button = UIButton(type: .custom)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        let attributedTitle = NSAttributedString(string: "LogOut", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem?.tintColor = .orange
        
    }
    
    private func setUpLeftButton(){
        if let navBar = navigationController?.navigationBar {
                navBar.tintColor = .orange
                navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
            }
    }
    
    
    
    //Get Data
    
    func retrieveData() {
        do {
            let db = SQLiteManager.shared().db
            guard let user = try db?.pluck(SQLiteManager.usersTable) else {
                print("No user data found")
                return
            }
            nameLabel.text = user[SQLiteManager.name]
            emailLabel.text = user[SQLiteManager.email]
            phoneLabel.text = String(user[SQLiteManager.phone])
            addressLabel.text = user[SQLiteManager.address]
            genderLabel.text = user[SQLiteManager.gender]
            if let imageData = user[SQLiteManager.image].flatMap({ UIImage(data: $0) }) {
                profileImageView.image = imageData
            }
        } catch {
            print("Cannot read data from table: \(error)")
        }
    }
    
    @objc private func addTapped(){
        logOut()
    }
    ///way 1
    private func goToSignInVC(){
        let signInVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.viewControllers = [signInVC, self]
        self.navigationController?.popViewController(animated: true)
    }
    ///way 2
    private func logOut(){
        // Set isSignedIn to false in UserDefaults
        UserDefaults.standard.set(false, forKey: "isSignedIn")
        
        let signInVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(signInVC, animated: true)
        
        
        
    }
    
}

