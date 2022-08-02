//
//  SizeTests.swift
//  store-platform-mvpTests
//
//  Created by Artem Lashmanov on 01.08.2022.
//

import XCTest
@testable import store_platform_mvp

class SizeTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitSizeModelInitSizePropertyToString() {
        let size = Size(size: .xl, price: 123, amount: 456)
        
        XCTAssertEqual(size.size, "xl")
    }
}
