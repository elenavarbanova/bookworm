//
//  ProfileViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 25.01.23.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signOutTappedButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch {
            print(error)
        }
        
    
    }
}
