//
//  SignUpVC.swift
//  MediaFinder11
//
//  Created by mohamed saad on 10/12/2022.
//

import UIKit
import SQLite
import CryptoKit

class SignUpVC: UIViewController {
    
    //MARK: - Outlets.
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var userImagefield: UIImageView!
    @IBOutlet weak var SwitchGender: UISwitch!
    //MARK: - Propreties.
    private let format = "SELF MATCHES %@"
    let switchGender = UISwitch()
    var imagePicker = UIImagePickerController()
    let hashPassword = { (password: String) -> Data in
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return Data(hashed)
    }
    
    var testEmail = ""
    var testPassword: Int64?
    
    
    
    //MARK: - Life Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    //MARK: - Actions.
    @IBAction func imageBtnTapped(_ sender: UIButton) {
        showPhotoAlert()
    }
    
    @IBAction func addressBtnTapped(_ sender: UIButton) {
        goToMapVC()
    }
    
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        signUpBtnActionTapped()
    }
    
    @IBAction func goToSignInBtn(_ sender: UIButton) {
        goToSignVC()
    }
    
}


//MARK: - Sending Address Protocol
//get data from MapVC
extension SignUpVC : MessageDelegation{
    func sendMessage(message : String){
        addressTextField.text = message
    }
}

//MARK: - Image section
extension SignUpVC : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func showPhotoAlert(){
        let alert = UIAlertController(title: "Take Photo From : ", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler: {action
            in
            self.getPhoto(type: .camera)
            
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default , handler: {action
            in
            self.getPhoto(type: .photoLibrary)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
        present(alert, animated: true)
    }
    
    func getPhoto(type : UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true , completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true , completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            print("Image Not Found")
            return
        }
        userImagefield.image = image
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true , completion: nil)
    }
}


//MARK: - privte methods
extension SignUpVC{
   private func setUpUI(){
        self.title = "Sign Up"
        UserDefaults.standard.set(false, forKey: "isSignedUp")
        makeRounded()
    }
    
    private func makeRounded() {
        userImagefield.layer.borderWidth = 1
        userImagefield.layer.masksToBounds = false
        userImagefield.layer.borderColor = UIColor.black.cgColor
        userImagefield.layer.cornerRadius = userImagefield.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
        userImagefield.clipsToBounds = true
    }
    
    
    func saveUserInputData() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let address = addressTextField.text,
              let phone = phoneTextField.text,
              let image = userImagefield.image,
              let genderValue = switchGender.isOn ? "Female" : "Male" else {
            print("Error: Missing required fields.")
            return
        }
        let hashedPassword = hashPassword(password)
        
        let user = User(name: name,
                        email: email,
                        password: hashedPassword,
                        address: address,
                        phone: Int64(phone)!,
                        image: image,
                        gender: genderValue)
        
        SQLiteManager.shared().saveUser(user)
        
        
        // Function to hash the password using SHA256
        func hashPassword(_ password: String) -> String {
            let passwordData = Data(password.utf8)
            let hashed = SHA256.hash(data: passwordData)
            return hashed.compactMap { String(format: "%02x", $0) }.joined()
        }
    }
    //Sign Up Button function
    private func signUpBtnActionTapped(){
        if isDataEnterd(){
            if isValidRegex(){
                saveUserInputData()
                // Show alert on success
                    let alertController = UIAlertController(title: "Success", message: "Your Account Has Been Created Successfully", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                        self.goToSignVC()
                    }))
                    present(alertController, animated: true, completion: nil)
            }
        }
    }
    private func goToSignVC(){
        let signInVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(signInVC, animated: true)
    }
    private func goToMapVC(){
        let mapVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        mapVC.delegate = self
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    //MARK: - Regex
    private func isValidEmail(email: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:format, emailRegEx)
        return emailPred.evaluate(with: email)
    }
    private func isValidPassword(Password: String) -> Bool{
        let PasswordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let PasswordPred = NSPredicate(format:format, PasswordRegEx)
        return PasswordPred.evaluate(with: Password)
    }
    private func isValidPhone(Phone: String) -> Bool{
        let PhoneRegEx = "^(00201|201|01)[0-2,5]{1}[0-9]{8}$"
        let PhonePred = NSPredicate(format:format, PhoneRegEx)
        return PhonePred.evaluate(with: Phone)
    }
    private func isValidRegex() -> Bool{
        guard isValidEmail(email: emailTextField.text!)else{
            self.showAlert(title: "Sorry", message: "Please Enter Valid Email. example: email@gmail.com ")
            return false
        }
        guard isValidPassword(Password: passwordTextField.text!)else{
            self.showAlert(title: "Sorry", message: "Please Enter Valid Password. example: Qq321459")
            return false
        }
        guard isValidPhone(Phone: phoneTextField.text!)else{
            self.showAlert(title: "Sorry", message: "Please Enter Valid Phone Number. example: 01017823902 ")
            return false
        }
        return true
    }
    private func isDataEnterd ()-> Bool {
        guard userImagefield.image != UIImage(named: "user") else{
            self.showAlert(title: "Sorry", message: "Please Enter Image For Your profile ")
            return false
        }
        guard nameTextField.text != "" else{
            self.showAlert(title: "Sorry", message: "Please Enter Name")
            return false
        }
        guard emailTextField.text != "" else{
            self.showAlert(title: "Sorry", message: "Please Enter Email")
            return false
        }
        guard passwordTextField.text != "" else{
            self.showAlert(title: "Sorry", message: "Please Enter Password")
            return false
        }
        guard phoneTextField.text != "" else{
            self.showAlert(title: "Sorry", message: "Please Enter Phone")
            return false
        }
        guard addressTextField.text != "" else{
            self.showAlert(title: "Sorry", message: "Please Enter Address")
            return false
        }
        return true
    }
}
