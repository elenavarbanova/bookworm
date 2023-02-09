//
//  DetailBookViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 1.02.23.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class DetailBookViewController: UIViewController {

    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorsStackView: UIStackView!
    var imageID: String?
    
    var book: Displayable? = nil
    var infoBook = [InfoBook]()
    var descriptionBook = String()
    var author = String()
    var authors: [String: String] = [:]
    var database = Firestore.firestore()
    
    enum BookList: Int {
    case tbr = 1
    case reading = 2
    case read = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchBookInfo()
        
        guard let authorNames = book?.authorNames else {
            return
        }
        
        let countNames = authorNames.count
        
        for auth in 0..<countNames {
            authors[authorNames[auth]] = book?.authorKeys?[auth]
            createButton(for: authorNames[auth])
        }
        
        createAddBookButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authorLabel.text = book?.subtitleLabelText
        bookTitleLabel.text = book?.titleLabelText


        guard let url = imageID else { return }
        
        let request = AF.request(url, method: .get)
        request.responseImage { response in
            guard let image = response.value else { return }
            DispatchQueue.main.async { [weak self] in
                self?.bookCoverImage.image = image
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let destination = segue.destination as? DetailAuthorViewController,
              let button = sender as? UIButton,
              let authorName = button.currentTitle else {
            return
        }
        
        destination.author = authors[authorName]!
    }
    
    func createButton(for title: String) {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        
        if title == "Unknown author" {
            button.setTitle(title, for: .disabled)
        } else {
            button.setTitle(title, for: .normal)
        }

        button.setTitleColor(.purple, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        authorsStackView.addArrangedSubview(button)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "authorInfoSegue", sender: sender)
    }
    
    func createAddBookButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Add Book"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemPurple
        
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.configuration = config
        
        let TBRAction = UIAction(title: "TBR", handler: { action in
            self.addBook(list: .tbr)
        })
        
        let CRAction = UIAction(title: "Currently reading", handler: { action in
            self.addBook(list: .reading)
        })
        
        let ReadAction = UIAction(title: "Read", handler: { action in
            self.addBook(list: .read)
        })
        
//        action.image = UIImage(systemName: "checkmark")
        
        button.menu = UIMenu(children: [
            TBRAction,
            CRAction,
            ReadAction
        ])
        
        button.frame = CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 25)
        view.addSubview(button)
    }
    
    func addBook(list: BookList) {
        guard let userId = Auth.auth().currentUser?.uid as? String,
              let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }
        
        self.database.collection("users/").document("\(userId)").collection("books").document("\(bookId)").setData(["book_state":list.rawValue]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}

extension DetailBookViewController {
    func fetchBookInfo() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let bookId = (book?.key as? NSString)?.lastPathComponent else { return }
        
        let request = AF.request("https://openlibrary.org/search.json?q=\(bookId)")
        request
            .validate()
            .responseDecodable(of: ResultInfoBook.self, decoder: decoder) { response in
                guard response.error == nil,
                      let info = response.value else {
                    return
                }
                
                self.infoBook = info.docs
            }
        
        let descriptionRequest = AF.request("https://openlibrary.org/works/\(bookId).json")
        descriptionRequest
            .validate()
            .responseDecodable(of: DescriptionBook.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else {
                    return
                }
                guard let description = response.value else { return }
                
                self?.descriptionBook = description.description.value
            }
    }
}
