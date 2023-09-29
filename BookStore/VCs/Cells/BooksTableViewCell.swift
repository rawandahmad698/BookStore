//
//  BooksTableViewCell.swift
//  BookStore
//
//  Created by Rawand Ahmad on 20/08/2023.
//

import UIKit

class BooksTableViewCell: UITableViewCell {
    weak var delegate: BooksTableViewCellDelegate?

    // Outlets
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookPrice: UILabel!
    
    // Constraints
    @IBOutlet weak var viewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var readMoreButton: UIButton!
    var isExpanded: Bool = false {
        didSet {
            if let constraint = viewHightConstraint {
                constraint.isActive = isExpanded
            }
        }
    }
    
    @IBAction func readMoreButtonTapped(_ sender: Any) {
        delegate?.didTapReadMoreButton(in: self)
    }
}

extension NSAttributedString {
     convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.unicode, allowLossyConversion: false) else {
            return nil
        }
        guard let attributedString = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString: attributedString)
    }
}
