//
//  ViewBookViewController.swift
//  BookStore
//
//  Created by Rawand Ahmad on 28/09/2023.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ViewBookViewController: UIViewController {
    var viewModel: ViewModel!

    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookPrice: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var openIBooks: UIButton!
    
    // Dispose Bag
    private let disposeBag = DisposeBag()

    var bookNameDriver: Driver<String?> {
        return viewModel.selectedBook.map { $0?.bookName }.asDriver(onErrorJustReturn: nil)
    }

    var bookPriceDriver: Driver<String?> {
        return viewModel.selectedBook.map { $0?.formattedPrice }.asDriver(onErrorJustReturn: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookNameDriver
            .drive(bookName.rx.text)
            .disposed(by: disposeBag)

        bookPriceDriver
            .drive(bookPrice.rx.text)
            .disposed(by: disposeBag)

        if let book = viewModel.selectedBook.value {
            bookDescription.attributedText = NSAttributedString(html: book.description)
            if let imageURL = URL(string: book.artwork.replacingOccurrences(of: "100x100bb", with: "600x600bb")) {
                self.bookImage.kf.setImage(with: imageURL)
            }
            
            self.openIBooks.rx.tap
                .bind {
                    if let bookURL = URL(string: book.iBooksURL) {
                        UIApplication.shared.open(bookURL, options: [:])
                    }
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
