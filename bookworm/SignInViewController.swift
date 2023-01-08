//
//  SignInViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 2.01.23.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
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
                if error != nil {
                    self.showError("Error signing in account!")
                } else {
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                }
            }
        }
    }
}
