//
//  BooksTableViewCell.swift
//  BookStore
//
//  Created by Rawand Ahmad on 20/08/2023.
//

import UIKit

class BooksTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookPrice: UILabel!
    
    // Constraints
    @IBOutlet weak var viewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionConstraint: NSLayoutConstraint!
    
    var isExpanded: Bool = false {
        didSet {
            if let constraint = viewHightConstraint {
                constraint.isActive = isExpanded
            }
        }
    }
}
