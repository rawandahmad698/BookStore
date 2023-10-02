//
//  BookStoreTests.swift
//  BookStoreTests
//
//  Created by Rawand Ahmad on 02/10/2023.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import BookStore


final class BookStoreTests: XCTestCase {
    var viewModel: ViewModel!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        viewModel = ViewModel()
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        disposeBag = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testMockFetchBooks() {
        let searchTerm = "Python"
        let books: [Book] = [Book(artwork: "A", bookName: "B", description: "C", formattedPrice: "$1", iBooksURL: "itunes.com")]
        
        let mockBookService = MockBookService(books: books)
        viewModel.bookService = mockBookService
        
        let observer = scheduler.createObserver([Book].self)
        viewModel.fetchBooks(for: searchTerm)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(viewModel.books.value.count, 1)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
class MockBookService: BookService {
    let books: [Book]

    init(books: [Book]) {
        self.books = books
    }

    override func fetchBooks(for searchTerm: String) -> Observable<[Book]> {
        return Observable.just(books)
    }
}
