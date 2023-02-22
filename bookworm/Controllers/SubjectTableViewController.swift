//
//  SubjectTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 22.02.23.
//

import UIKit
import Alamofire
import AlamofireImage

class SubjectTableViewController: UITableViewController {

    var items = [Displayable]()
    var subject = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = subject
        fetchBooksBySubject()
        setupTableViewBackgroundView()
    }
    
    func setupTableViewBackgroundView() {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        tableView.backgroundView = activityIndicator
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell
     
        let eachBook = items[indexPath.row]
        cell.bookTitleLabel?.text = eachBook.titleLabelText
        cell.authorLabel?.text = eachBook.subtitleLabelText
     
        if let imageID = eachBook.image {
            cell.imageID = imageID
            let request = AF.request(imageID, method: .get)
            request.responseImage { response in
                guard let image = response.value else {
                    return
                }
                DispatchQueue.main.async {
                    if cell.imageID == imageID {
                        cell.bookCoverImage.image = image
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SubjectTableViewController {
    func fetchBooksBySubject() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let searchSubject = subject.replacingOccurrences(of: " ", with: "_").lowercased()
        let request = AF.request("https://openlibrary.org/subjects/\(searchSubject).json")
        request
            .validate()
            .responseDecodable(of: Books.self, decoder: decoder) { response in
                guard let books = response.value else { return }
                
                self.items = books.allBooks
                self.tableView.reloadData()
            }
    }
}
