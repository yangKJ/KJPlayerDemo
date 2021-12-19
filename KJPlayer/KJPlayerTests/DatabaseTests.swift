//
//  Database.swift
//  KJPlayerTests
//
//  Created by abas on 2021/12/14.
//

import XCTest
import KJPlayer

class Database: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDatabase() throws {
        let dbid = "testdbid" + "\(arc4random() % 77)"
        
        let model = DatabaseManager.queryOne(with: dbid)
        XCTAssertNil(model)
        
        let data = PlayerVideoData.init(context: DatabaseManager.context)
        data.dbid = dbid
        data.videoUrl = "https://www.baidu.com"
        data.videoDownloaded = true
        data.videoTotalTime = Double(arc4random() % 200)
        
        let x = DatabaseManager.insert(with: data)
        XCTAssertTrue(x, "insert successed")
        
        let m2 = DatabaseManager.queryOne(with: dbid)!
        XCTAssertNotNil(m2, "\(m2)")
        
        data.videoUrl = "https://github.com"
        let b = DatabaseManager.update(with: data, playedTime: nil)
        XCTAssertTrue(b, "update successed")
        
        let m3 = DatabaseManager.queryOne(with: dbid)!
        XCTAssertNotNil(m3, "\(m3)")
        
        let d = DatabaseManager.delete(with: dbid)
        XCTAssertTrue(d, "delete successed")
        
        let m4 = DatabaseManager.queryOne(with: dbid)
        XCTAssertNil(m4)
    }
}
