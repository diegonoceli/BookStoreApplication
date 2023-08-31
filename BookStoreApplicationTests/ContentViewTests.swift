//
//  ContentViewTests.swift
//  BookStoreApplicationTests
//
//  Created by Diego Noceli on 31/08/23.
import XCTest
import BookStore
@testable import BookStoreApplication

class ContentViewTests: XCTestCase {
    var contentView: ContentView!
    var sampleBooksData: Data!

    override func setUp() {
        super.setUp()

        contentView = ContentView()

        let sampleBooksJSON = """
        [
            {
                "id": "1234",
                "title": "Book 1",
                "authors": ["Author 1"],
                "description": "Description 1",
                "thumbnailURL": "https://example.com/image1.jpg",
                "buyLinkURL": "https://example.com/buy1",
                "isFavorite": true
            },
            {
                "id": "1234",
                "title": "Book 2",
                "authors": ["Author 2"],
                "description": "Description 2",
                "thumbnailURL": "https://example.com/image2.jpg",
                "buyLinkURL": "https://example.com/buy2",
                "isFavorite": false
            }
        ]
        """

        sampleBooksData = sampleBooksJSON.data(using: .utf8)
    }

    override func tearDown() {
        contentView = nil
        sampleBooksData = nil
        super.tearDown()
    }

    func testDecodingBooksFromJSON() {
        XCTAssertNotNil(sampleBooksData)
        do {
            let books = try JSONDecoder().decode([Book].self, from: sampleBooksData)
            XCTAssertEqual(books.count, 2)
        } catch {
            XCTFail("Failed to decode books from JSON: \(error)")
        }
    }
    
    func testContentViewWithBooks() {
        do {
            let books = try JSONDecoder().decode([Book].self, from: sampleBooksData)
            let localContentView = ContentView(books: books)
            XCTAssertTrue(localContentView.books.count == books.count, "The 'books' array should be populated.")
        } catch {
            XCTFail("Failed to decode books from JSON: \(error)")
        }
    }
    
    func testFavoriteWithBooks() {
        do {
            let books = try JSONDecoder().decode([Book].self, from: sampleBooksData)
            let localContentView = ContentView(books: books,showFavoritesOnly: true)
            
            XCTAssertTrue(localContentView.books[0].title == "Book 1", "Book 1 should be the only favorite book")
        } catch {
            XCTFail("Failed to decode books from JSON: \(error)")
        }
    }
}
