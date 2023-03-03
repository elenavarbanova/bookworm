//
//  SignInViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 2.01.23.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func validateTextFields() -> String? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "All fields are required!"
        }
        return nil
    }
    
    func showError(_ errorMessage: String) {
        errorLabel.text = errorMessage
        errorLabel.alpha = 1
    }
    
    @IBAction func signInTappedButton(_ sender: Any) {
        let error = validateTextFields()
        if error != nil {
            showError(error!)
        } else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                guard error == nil else {
                    self.showError("Error signing in account!")
                    return
                }
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            }
            emailTextField.text?.removeAll()
            passwordTextField.text?.removeAll()
        }
    }
}
