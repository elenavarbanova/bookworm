//
//  WelcomeViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 2.01.23.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserLoggedIn()
    }
    
    private func checkUserLoggedIn() {
        guard Auth.auth().currentUser != nil else {
            return
        }
        self.performSegue(withIdentifier: "loggedIn", sender: nil)
    }
    
}
