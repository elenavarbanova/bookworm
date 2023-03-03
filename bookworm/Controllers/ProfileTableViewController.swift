//
//  ProfileViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 25.01.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ProfileTableViewController: UITableViewController {
    
    var database = Firestore.firestore()
    var TBRBooks = Int()
    var readingBooks = Int()
    var readBooks = Int()
    var user = Auth.auth().currentUser

    enum Sections: Int, CaseIterable {
        case Statistics = 0
        case UpdateProfile = 1
        case SignOut = 2
    }
    
    enum BookList: Int {
        case tbr = 1
        case reading = 2
        case read = 3
    }
    
    var updateProfile = ["Change Email", "Change password"]
    var updates = ["Enter new email", "Enter new password"]
    var signOut = ["Sign out", "Delete profile"]
    var buttons = ["Sign out", "Delete"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        getBooks(list: .tbr)
        getBooks(list: .reading)
        getBooks(list: .read)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Sections.Statistics.rawValue {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Statistics", for: indexPath) as! StatisticsTableViewCell
                cell.TBRLabel.text = "\(TBRBooks)"
                cell.ReadingLabel.text = "\(readingBooks)"
                cell.ReadLabel.text = "\(readBooks)"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.textProperties.color = .systemPurple
                content.textProperties.alignment = .center
                content.text = "Read books"
                cell.contentConfiguration = content
                return cell
            }
        } else if indexPath.section == Sections.UpdateProfile.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .systemPurple
            content.textProperties.alignment = .center
            content.text = updateProfile[indexPath.row]
            cell.contentConfiguration = content
            return cell
        } else if indexPath.section == Sections.SignOut.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.textProperties.alignment = .center
            content.text = signOut[indexPath.row]
            if indexPath.row == 0 {
                content.textProperties.color = .systemPurple
            } else if indexPath.row == 1 {
                content.textProperties.color = .systemRed
            }
            cell.contentConfiguration = content
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Sections.Statistics.rawValue, indexPath.row == 0 {
            return 100
        }
        return 50
    }
    
    func updateProfileAlert(_ indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Change personal information",
            message: updateProfile[indexPath.row],
            preferredStyle: .alert)
        alert.view.tintColor = .systemPurple
        if indexPath.row == 0 {
            alert.addTextField { textField in
                textField.placeholder = self.updates[indexPath.row]
            }
            alert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Еnter current password"
            }
        }
        if indexPath.row == 1 {
            alert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Еnter current password"
            }
            alert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Еnter new password"
            }
            alert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = self.updates[indexPath.row]
            }
        }
        let actionCancel = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        let actionUpdate = UIAlertAction(
            title: "Update",
            style: .default) { action in
                if indexPath.row == 0 {
                    guard let email = alert.textFields?.first?.text as? String,
                          let currentPassword = alert.textFields?[1].text as? String else {
                        return
                    }
                    self.authenticateUserEmail(for: email, for: currentPassword)
                } else {
                    guard let newPassword = alert.textFields?[0].text as? String,
                          let oldPasssword = alert.textFields?[1].text,
                          let confirmPassword = alert.textFields?[2].text else {
                        return
                    }
                    
                    self.authenticateUserPassword(for: newPassword, for: oldPasssword, for: confirmPassword)
                }
            }
        alert.addAction(actionCancel)
        alert.addAction(actionUpdate)
        self.present(alert, animated: true, completion: nil)
    }
    
    func profile(_ indexPath: IndexPath) {
        let alert = UIAlertController(
            title: signOut[indexPath.row],
            message: "Are you sure?",
            preferredStyle: .alert)
        alert.view.tintColor = .systemPurple
        if indexPath.row == 1 {
            alert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Еnter password"
            }
        }
        let actionCancel = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        let actionDestructive = UIAlertAction(
            title: buttons[indexPath.row],
            style: .destructive) { action in
                if indexPath.row == 0 {
                    self.signOutButton()
                } else {
                    guard let password = alert.textFields?.first?.text as? String else {
                        return
                    }
                    self.reauthenticateDelete(password)
                }
            }
        alert.addAction(actionDestructive)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Sections.Statistics.rawValue {
            if indexPath.row == 1{
                performSegue(withIdentifier: "showReadBooks", sender: nil)
            }
        } else if indexPath.section == Sections.UpdateProfile.rawValue {
            updateProfileAlert(indexPath)
        } else if indexPath.section == Sections.SignOut.rawValue {
            profile(indexPath)
        }
    }
    
    func validatePassword(_ password: String, _ confirmPassword: String) -> String? {
        if password != confirmPassword {
            return "Please make sure your passwords match!"
        }
            
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if checkPassword(cleanedPassword) == false {
            return "The password does not meet the password policy requirements!"
        }
        return nil
    }
    
    func validateEmail(_ email: String) -> String? {
        
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    func updateEmail(for email: String) {
        let error = self.validateEmail(email)
        if error != nil {
            print(error!)
        } else {
            Auth.auth().currentUser?.updateEmail(to: email) { error in
                guard error == nil else {
                    return
                }
            }
        }
    }
    
    func authenticateUserEmail(for email: String, for password: String) {
        
        self.updateEmail(for: email)
        
        guard let currentEmail = Auth.auth().currentUser?.email else {
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)

        user?.reauthenticate(with: credential) { result,_  in
            guard result != nil else {
                print(result!)
                return
            }
            self.updateEmail(for: email)
        }
        
       
    }
    
    func updatePassword(for password: String, for confirmPassword: String) {
        let error = self.validatePassword(password, confirmPassword)
        if error != nil {
            print(error!)
        } else {
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                guard error == nil else {
                    print(error!)
                    return
                }
            }
        }
    }
    
    func authenticateUserPassword(for oldPassword: String, for password: String, for confirmPassword: String) {
        
        updatePassword(for: password, for: confirmPassword)
        
        guard let email = Auth.auth().currentUser?.email else {
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        user?.reauthenticate(with: credential) { result,_  in
            guard result != nil else {
                print(result as Any)
                return
            }
            self.updatePassword(for: password, for: confirmPassword)
        }
    }
    
    func deleteProfile(){
        guard let userId = user?.uid as? String else {
            return
        }
        
        user?.delete { [weak self] error in
            guard error == nil else {
                print(error!)
                return
            }

            self?.database.collection("users").document(userId).collection("books").getDocuments(completion: { querySnapshot, error in
                
                querySnapshot?.documents.forEach({ document in
                    document.reference.delete()
                })
            })
            
            self?.database.collection("users").document(userId).delete() { error in
                guard error == nil else {
                    print(error!)
                    return
                }
            }
            self?.signOutButton()
        }
    }
    
    func reauthenticateDelete(_ password: String) {
        deleteProfile()
        
        guard let email = user?.email else {
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticate(with: credential) { result,_  in
            guard result != nil else {
                print(result as Any)
                return
            }
            self.deleteProfile()
        }
    }
    
    func signOutButton() {
        do {
            try Auth.auth().signOut()
            self.tabBarController?.dismiss(animated: true)
            if let rootNavigationCtonroller = self.navigationController?.presentingViewController as? UINavigationController {
                rootNavigationCtonroller.popToRootViewController(animated: true)
            }
        } catch {
            print(error)
        }
    }
    
    func getBooks(list: BookList) {
        guard let userId = user?.uid as? String else {
            return
        }
        database.collection("users").document(userId).collection("books").whereField("book_state", isEqualTo: list.rawValue).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            if list.rawValue == BookList.tbr.rawValue {
                self?.TBRBooks = documents.count
            } else if list.rawValue == BookList.reading.rawValue {
                self?.readingBooks = documents.count
            } else if list.rawValue == BookList.read.rawValue {
                self?.readBooks = documents.count
            }
            self?.tableView.reloadData()
        }
    }
}
