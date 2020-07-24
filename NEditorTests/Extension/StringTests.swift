//
//  StringTests.swift
//  NEditorTests
//
//  Created by 417.72KI on 2020/07/24.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import XCTest
@testable import NEditor

class StringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMatchesWithWildcard() throws {
        XCTContext.runActivity(named: "partial = true") { _ in
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "x***y", partial: true))
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "x***x", partial: true))
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "x***x?", partial: true))
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "*", partial: true))

            XCTAssertFalse("a12b34c".matches(withWildcard: "a?b?c", partial: true))
            XCTAssertTrue("a12b34c".matches(withWildcard: "a*b*c", partial: true))
        }
        XCTContext.runActivity(named: "partial = false") { _ in
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "x***y", partial: false))
            XCTAssertFalse("xyxzzxy".matches(withWildcard: "x***x", partial: false))
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "x***x?", partial: false))
            XCTAssertTrue("xyxzzxy".matches(withWildcard: "*", partial: false))

            XCTAssertFalse("a12b34c".matches(withWildcard: "a?b?c", partial: false))
            XCTAssertTrue("a12b34c".matches(withWildcard: "a*b*c", partial: false))
        }
    }
}
