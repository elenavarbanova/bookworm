//
//  DetailAuthorViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 5.02.23.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailAuthorViewController: UIViewController {
    
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var authorName: UILabel!

    var authorInfo: Author? = nil
    var author = String()
    var works = [AuthorWorks]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAuthorInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authorName.text = author
    }
}

extension DetailAuthorViewController {
    func fetchAuthorInfo() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let authorId = (author as NSString).lastPathComponent
        
        let request = AF.request("https://openlibrary.org/authors/\(authorId).json")
        request
            .validate()
            .responseDecodable(of: Author.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else { return }
                guard let info = response.value else { return }
                
                self?.authorInfo = info
                
                guard let authorImage = self?.authorInfo?.photos?.first else {
                    return
                }
                
                let imageId = String(authorImage)
                
                let requestImage = AF.request("https://covers.openlibrary.org/b/id/\(imageId)-M.jpg", method: .get)
                requestImage.responseImage { [weak self] response in
                    guard let image = response.value else { return }
                    DispatchQueue.main.async { [weak self] in
                        self?.authorImage.image = image
                    }
                }
             }
        
        let requestWorks = AF.request("https://openlibrary.org/authors/\(authorId)/works.json")
        requestWorks
            .validate()
            .responseDecodable(of: Works.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else { return }
                guard let info = response.value else { return }
                
                self?.works = info.entries
            }
    }
}
