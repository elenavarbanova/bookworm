//
//  RegisterViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 2.01.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak private var errorLabel: UILabel!
    @IBOutlet weak private var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func validateTextFields() -> String? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "All fields are required!"
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            return "Please make sure your passwords match!"
        }
            
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if checkPassword(cleanedPassword) == false {
            return "The password does not meet the password policy requirements!"
        }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if checkEmail(cleanedEmail) == false {
            return "The email does not meet the email policy requirements!"
        }
        
        return nil
    }
    
    private func checkPassword(_ password: String) -> Bool {
        let passwordRegEx = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}")
        return passwordRegEx.evaluate(with: password)
    }
    
    private func checkEmail(_ email: String) -> Bool {
        let emailRegEx = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailRegEx.evaluate(with: email)
    }
    
    func showError(_ errorMessage: String) {
        errorLabel.text = errorMessage
        errorLabel.alpha = 1
    }
    
    @IBAction func signUpTappedButton(_ sender: Any) {
        
        let error = validateTextFields()
        if error != nil {
            showError(error!)
        } else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                guard error == nil else {
                    self.showError("Error creating user!")
                    return
                }
                if Auth.auth().currentUser != nil {
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                    let database = Firestore.firestore()
                    guard let userId = Auth.auth().currentUser?.uid as? String else {
                        return
                    }
                    database.collection("users").document("\(userId)").setData([:]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else  {
                    self.performSegue(withIdentifier: "signUpSegue", sender: nil)
                }
            }
        }
    }
}
