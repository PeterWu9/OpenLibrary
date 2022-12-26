//
//  BooksTableViewCell.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/13/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit

class BooksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var task: Task<Void, Error>?
    var book: Book?
    
    override func prepareForReuse() {
        // reset cell's label and image
        titleLabel.text = ""
        authorLabel?.text = ""
        cellImageView.image = nil
        task?.cancel()
        task = nil
    }
    
    func configure(with book: Book, task: Task<Void, Error>) {
        self.book = book
        titleLabel.text = book.title
        if let authors = book.author {
            authorLabel.text = authors[0].name
        }
        self.task = task        
    }
    
    
}
