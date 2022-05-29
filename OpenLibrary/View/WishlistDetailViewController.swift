//
//  WishlistDetailViewController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/14/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit

class WishlistDetailViewController: UIViewController {
    
    var bookModel: BookModel?
    var booksController = BooksController()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionsCountLabel: UILabel!
    @IBOutlet weak var publishedYearLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfPagesLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let bookModel = bookModel {
            updateUI(for: bookModel)
        }
    }
    
    
    
    func updateUI(for bookModel: BookModel) {
        
        clearUI()
        
        titleLabel.text = bookModel.title
        editionsCountLabel.text = String(bookModel.editionsCount) + " editions"
        
        if let author = bookModel.author {
            authorLabel.text = "By: " + author
        }
        if bookModel.publishYear > 0 {
            publishedYearLabel.text = "First published in: " + String(Int(bookModel.publishYear))
        }
        
        if bookModel.coverID > 0 {
            booksController.fetchCoverImage(coverID: Int(bookModel.coverID), imageSize: .large) { [weak self] (fetchedImage) in
                if let coverImage = fetchedImage, let weakSelf = self {
                    DispatchQueue.main.async {
                        weakSelf.coverImageView.image = coverImage
                    }
                }
            }
        }
        
        if let bookID = bookModel.lendingEditionID {
            booksController.fetchDetails(fromID: bookID) { [weak self] (bookDetail) in
                guard let weakSelf = self, let detail = bookDetail else { return }
                DispatchQueue.main.async {
                    weakSelf.descriptionLabel.text = detail.description
                    weakSelf.numberOfPagesLabel.text = detail.numberOfPages != nil ? String(detail.numberOfPages!) +
                        " pages" : ""
                    if let subjects = detail.subjects {
                        weakSelf.subjectsLabel.text = "SUBJECTS:\n" + subjects
                    }
                }
            }
        }
    }
    
    func clearUI() {
        // Reset all UI elements
        titleLabel.text = ""
        coverImageView.image = nil
        authorLabel.text = ""
        editionsCountLabel.text = ""
        publishedYearLabel.text = ""
        descriptionLabel.text = ""
        numberOfPagesLabel.text = ""
        subjectsLabel.text = ""
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
