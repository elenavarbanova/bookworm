//
//  DetailAuthorTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 22.02.23.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailAuthorTableViewController: UITableViewController {
    
    var authorInfo: Author? = nil
    var author = String()
    var authorName = String()
    var works = [AuthorWorks]()
    var worksIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAuthorInfo()
        navigationItem.title = authorName
    }
    
    enum Sections: Int, CaseIterable {
        case AuthorHeader = 0
        case Bio = 1
        case AlternativeNames = 2
        case MoreBooks = 3
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Sections.AuthorHeader.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorHeader", for: indexPath) as! AuthorHeaderTableViewCell
            cell.birthdayLabel.text = authorInfo?.birthDate
            
            return cell
        } else if indexPath.section == Sections.Bio.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Bio", for: indexPath) as! BioTableViewCell
            if authorInfo?.bio == nil {
                cell.isHidden = true
            } else {
                cell.bioLabel.text = authorInfo?.bio
            }
            return cell
        } else if indexPath.section == Sections.AlternativeNames.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlternativeNames", for: indexPath) as! AlternativeNamesTableViewCell
            guard let countNames = authorInfo?.alternateNames?.count else {
                return cell
            }
            for names in 0..<countNames {
                createAlternativeNames(for: (authorInfo?.alternateNames?[names])!, for: cell)
            }
            return cell
        } else if indexPath.section == Sections.MoreBooks.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreBooks", for: indexPath) as! MoreBooksTableViewCell
            cell.bookIDs = worksIDs
            return cell
        }
        return UITableViewCell()
    }
    
    func createAlternativeNames(for name: String, for cell: AlternativeNamesTableViewCell) {
        let label = UILabel()
        label.text = name
        cell.alternativeNamesStackView.addArrangedSubview(label)
    }
    
    func getIDs() {
        let countBooks = works.count
        for book in 0..<countBooks {
            let workId = (works[book].key as NSString).lastPathComponent
            worksIDs.append(workId)
        }
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

extension DetailAuthorTableViewController {
    func fetchAuthorInfo() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let authorId = (author as NSString).lastPathComponent
        
        let request = AF.request("https://openlibrary.org/authors/\(authorId).json")
        request
            .validate()
            .responseDecodable(of: Author.self, decoder: decoder) { [weak self] response in
                guard response.error == nil,
                      let info = response.value,
                      let authorImage = info.photos?.first else {
                    return
                }
                
                self?.authorInfo = info
                
                let imageId = String(authorImage)
                
                let requestImage = AF.request("https://covers.openlibrary.org/b/id/\(imageId)-M.jpg", method: .get)
                requestImage.responseImage { response in
                    guard let image = response.value else { return }
                    DispatchQueue.main.async { [weak self] in
                        let indexPath = IndexPath(row: 0, section: Sections.AuthorHeader.rawValue)
                        let cell = self?.tableView.cellForRow(at: indexPath) as? AuthorHeaderTableViewCell
                        cell?.authorPhotoImage.image = image
                        self?.tableView.reloadData()
                    }
                }
             }
        
        let requestWorks = AF.request("https://openlibrary.org/authors/\(authorId)/works.json")
        requestWorks
            .validate()
            .responseDecodable(of: Works.self, decoder: decoder) { [weak self] response in
                guard response.error == nil,
                      let info = response.value else {
                    return
                }
                
                self?.works = info.entries
                self?.getIDs()
                self?.tableView.reloadData()
            }
    }
}
