//
//  MovieApiCommunicatorTest.swift
//  PVTest
//
//  Created by Ashish Mishra on 4/24/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import XCTest
@testable import PVTest

class MovieApiCommunicatorTest: XCTestCase {
    
    var  sessionTest : URLSession!
    var topRatedVC : TopRatedMovieListViewController?
    
    override func setUp() {
        super.setUp()
        sessionTest = URLSession(configuration: URLSessionConfiguration.default)
        topRatedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopRatedVC") as? TopRatedMovieListViewController

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sessionTest = nil
        super.tearDown()
    }
    
    func testValidCallToGenreList() {
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/genre/movie/list?language=en-US&api_key=\(APIkey)"
        
        let urlString:String = APIBaseUrl
        let url = URL(string: urlString)
        _ = URLRequest(url: url!);
        
        let promise = expectation(description: "Completion handler invoked")
        
        // when
        let dataTask = sessionTest.dataTask(with: url!) { data, response, error in
            // then
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    // 2
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        // 3
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testValidCallToTopRatedMovies() {
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/movie/top_rated?api_key="
        
        let urlString:String = "\(APIBaseUrl)" + "\(APIkey)";
        
        let url = URL(string: urlString)
        _ = URLRequest(url: url!);
        
        let promise = expectation(description: "Completion handler invoked")
        
        // when
        let dataTask = sessionTest.dataTask(with: url!) { data, response, error in
            // then
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    // 2
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        // 3
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
