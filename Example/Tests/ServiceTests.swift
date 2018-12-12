//
//  ServiceTests.swift
//  ViteWallet_Tests
//
//  Created by Stone on 2018/12/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import ViteWallet

class ServiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Provider.default.update(server: RPCServer(url: URL(string: "http://45.40.197.46:48132")!))
        LogConfig.instance.isEnable = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func async(_ block: ( @escaping () -> () ) -> ()) {

        let expect = expectation(description: "method")
        block {
            expect.fulfill()
        }
        waitForExpectations(timeout: 6000000, handler: nil)
        print("🍺🍺🍺🍺🍺🍺")

    }

    func testReceiveTransactionService() {
        let service = ReceiveTransactionService(account: Box.secondAccount) { r in
            printLog(r)
        }

        async { (completion) in
            service.register(interval: 2)

            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                printLog("stop")
                service.unregister()
            })
        }
    }

    func testFetchBalanceInfoService() {
        let service = FetchBalanceInfoService(address: Box.secondAccount.address) { r in
            printLog(r)
        }

        async { (completion) in
            service.register(interval: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                printLog("stop")
                service.unregister()
            })
        }
    }

    func testFetchPledgeQuotaService() {
        let service = FetchPledgeQuotaService(address: Box.firstAccount.address) { r in
            printLog(r)
        }

        async { (completion) in
            service.register(interval: 1)
        }
    }
}
