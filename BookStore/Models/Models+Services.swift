//
//  Models+Services.swift
//  BookStore
//
//  Created by Rawand Ahmad on 20/08/2023.
//
import UIKit
import RxSwift
import RxCocoa

struct SearchResponse: Decodable {
    let resultCount: Int
    let results: [Book]
}

struct Book: Decodable {
    let artwork: String
    let bookName: String
    let description: String
    let formattedPrice: String
    let iBooksURL: String
    
    private enum CodingKeys: String, CodingKey {
        case description
        case formattedPrice
        case artwork = "artworkUrl100"
        case bookName = "trackName"
        case iBooksURL = "trackViewUrl"
    }
}

enum ApiError: Error {
    case bookNotFound
    case serverFailure
}

class BookService {
    func fetchBooks(for searchTerm: String) -> Observable<[Book]> {
        guard let url = URL(string: "https://itunes.apple.com/search") else {
            return Observable.just([])
        }
        let params = [
            "media": "ebook",
            "term": searchTerm
        ]
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

        let request: Observable<URLRequest> = Observable.create { observer in
            var request = URLRequest(url: url)
            let queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            urlComponents.queryItems = queryItems
            
            request.url = urlComponents.url!
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Accept": "*/*",
                "Accept-Language": "en;q=1.0, ckb-US;q=0.9",
                "User-Agent": "Postman Runtime via BookStore",
                "X-Forwarded-For": "8.8.8.8"
            ]
            observer.onNext(request)
            observer.onCompleted()
            
            return Disposables.create()
        }
        let session = URLSession.shared
        return request.flatMap { request in
            return session.rx.response(request: request)
                .map { response, data in
                    switch response.statusCode {
                    case 200 ..< 300:
                        let decoder = JSONDecoder()
                        do {
                            let response = try decoder.decode(SearchResponse.self, from: data)
                            if response.resultCount == 0 {
                                throw ApiError.bookNotFound
                            }
                            return response.results
                        } catch {
                            throw ApiError.bookNotFound
                        }
                    case 400 ..< 500:
                        throw ApiError.bookNotFound
                    default:
                        throw ApiError.serverFailure
                    }
                }
        }
    }
}


class ViewModel {
    private let bookService = BookService()
    private let disposeBag = DisposeBag()
    
    let books = BehaviorRelay<[Book]>(value: [])
    let selectedBook = BehaviorRelay<Book?>(value: nil)
    
    func fetchBooks(for searchTerm: String) -> Observable<[Book]> {
        return bookService.fetchBooks(for: searchTerm)
            .do(onNext: { [weak self] books in
                self?.books.accept(books)
            })
    }
}

protocol BooksTableViewCellDelegate: AnyObject {
    func didTapReadMoreButton(in cell: BooksTableViewCell)
}
