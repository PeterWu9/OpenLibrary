//
//  BookDetailViewController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/11/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import Combine

class BookDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var book: Book
    var viewModel: BooksViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionsCountLabel: UILabel!
    @IBOutlet weak var publishedYearLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfPagesLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var heartImage: UIImageView!
    
    init?(coder: NSCoder, book: Book, viewModel: BooksViewModel) {
        self.book = book
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI(for: book)
    }
    
    fileprivate func updateFavorites(for book: Book) {
        favoriteButton.setTitle(book.isFavorite ? "Unfavorite" : "Favorite", for: .normal)
        let imageName = book.isFavorite ? "heart.fill" : "heart"
        heartImage.image = UIImage(systemName: imageName)
    }
    
    private func setupUI(for book: Book) {
        print(#function, "book: \(book)")
        clearUI()
                
        titleLabel.text = book.title
        editionsCountLabel.text = String(book.editionsCount) + " editions"
        
        if let names = book.author?.concatedNames {
            authorLabel.text = names
        }
        
        if let publishedYear = book.publishYear {
            publishedYearLabel.text = "First published in: " + String(publishedYear)
        }
                
        updateFavorites(for: book)
        
        
        if let coverID = book.coverID {
            Task {
                coverImageView.image = try? await viewModel.fetchCoverImage(coverID: coverID, imageSize: .large)
            }
        }
        
        if let bookID = book.lendingEditionID {
            Task {
                do {
                    let detail = try await viewModel.fetchDetails(fromID: bookID)
                    descriptionLabel.text = detail.description
                    if let numberOfPages = detail.numberOfPages {
                        numberOfPagesLabel.text = "\(numberOfPages) pages"
                    }
                    if let subjects = detail.subjects {
                        subjectsLabel.text = "SUBJECTS:\n" + subjects
                    }

                } catch {
                    print(error)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Determine current position in table view
        let currentOffset = scrollView.contentOffset.y
        let titleLableOffset = titleLabel.frame.height
        
        // Only show title when scrolling past the title label
        if (currentOffset > titleLableOffset) {
            self.title = book.title
        } else {
            self.title = nil
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        // Note the contrast of having to update UI imperatively
        // we're reacting to an event, "favorite button tapped"
        // rather than observing and reacting to the change of state
        // like a change in the book model's isfavorite status
        book.isFavorite.toggle()
        updateFavorites(for: book)
        viewModel.update(book)
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
