//
//  BookDetailViewController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/11/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import CoreData

class BookDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var book: Book?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionsCountLabel: UILabel!
    @IBOutlet weak var publishedYearLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfPagesLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!
    @IBOutlet weak var wishListAddButton: UIButton!
    
    var booksController: BooksController!
    var container: PersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        booksController = BooksController()

        // Do any additional setup after loading the view.
        if let book = book {
            updateUI(for: book)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        booksController = nil
        container = nil;
    }
    
    func updateUI(for book: Book) {
        
        clearUI()
                
        titleLabel.text = book.title
        editionsCountLabel.text = String(book.editionsCount) + " editions"
        
        if let names = book.author?.concatedNames {
            authorLabel.text = names
        }
        
        if let publishedYear = book.publishYear {
            publishedYearLabel.text = "First published in: " + String(publishedYear)
        }
        
        if let coverID = book.coverID {
            booksController.fetchCoverImage(coverID: coverID, imageSize: .large) { [weak self] (fetchedImage) in
                if let coverImage = fetchedImage, let weakSelf = self {
                    DispatchQueue.main.async {
                        weakSelf.coverImageView.image = coverImage
                    }
                }
            }
        }
        
        if let bookID = book.lendingEditionID {
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
        
        // Check if the book is already saved in the favorite list
        let request: NSFetchRequest<BookModel> = BookModel.fetchRequest()
        print("key: \(book.key)")
        let predicate = NSPredicate(format: "key = %@", book.key)
        request.predicate = predicate
        let context = container.viewContext
        
        if let count = try? context.count(for: request), count > 0 {
            // disables wishlist button
            print("book already in database")
            wishListAddButton.isEnabled = false
        }
    }
    
    @IBAction func wishListButtonTapped(_ sender: UIButton) {
        // Save to favorite
        let context = container.viewContext
        
        guard let book = book else { return }
        let bookModel = BookModel(context: container.viewContext)
        bookModel.title = book.title
        if let coverID = book.coverID { bookModel.coverID = Int32(coverID)}
        bookModel.editionsCount = Int32(book.editionsCount)
        bookModel.key = book.key
        bookModel.lendingEditionID = book.lendingEditionID
        bookModel.author = book.author?.concatedNames
        
        if let publishYear = book.publishYear { bookModel.publishYear = Int32(publishYear) }
        
        do {
            try context.save()
            printDatabaseStatistics()
            
            // disable favoriteButton
            wishListAddButton.isEnabled = false
            
        } catch {
            print("Error saving context")
            print(error)
        }
    }
    
    private func printDatabaseStatistics() {
        let context = container.viewContext
        context.perform { [unowned context] in
            if let count = try? context.count(for: BookModel.fetchRequest()) {
                print("books count: \(count)")
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
        wishListAddButton.isEnabled = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Determine current position in table view
        let currentOffset = scrollView.contentOffset.y
        let titleLableOffset = titleLabel.frame.height
        
        // Only show title when scrolling past the title label
        if (currentOffset > titleLableOffset) {
            self.title = book!.title
        } else {
            self.title = nil
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
