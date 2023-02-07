//
//  DetailBookViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 1.02.23.
//

import UIKit
import Alamofire
import AlamofireImage

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
