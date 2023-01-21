//
//  UserDataTests.swift
//  store-platform-mvpTests
//
//  Created by Artem Lashmanov on 30.07.2022.
//

import XCTest
import FirebaseFirestore

@testable import store_platform_mvp

class UserDataTests: XCTestCase {
    
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    func testInitUserDataWithoutDetails() {
        let userData = UserData(id: "Foo", firstName: "Bar", lastName: "FooBar", email: "FooBar@gmail.com")
        
        XCTAssertNil(userData.details)
    }
    
    func testEncodingUserDataWithDetails() {
        var result: Int?
        
        let details = UserDetails(phone: "Foo", city: "Bar", street: "Foo", house: "Bar", apartment: "Foo", postalCode: "Bar")
        let userData = UserData(id: "Foo", firstName: "Bar", lastName: "FooBar", email: "FooBar@gmail.com", details: details)
        let encoder = Firestore.Encoder()
        
        guard let _ = try? encoder.encode(userData) else {
            result = nil; return
        }
        
        result = 1
        XCTAssertNotNil(result)
    }
    
    func testEncodingUserDataWithoutDetails() {
        var result: Int?
        
        let userData = UserData(id: "Foo", firstName: "Bar", lastName: "FooBar", email: "FooBar@gmail.com")
        let encoder = Firestore.Encoder()
        
        guard let _ = try? encoder.encode(userData) else {
            result = nil; return
        }
        
        result = 1
        XCTAssertNotNil(result)
    }
}
