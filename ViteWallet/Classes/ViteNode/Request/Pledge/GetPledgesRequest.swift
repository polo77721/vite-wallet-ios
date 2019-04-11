//
//  GetPledgesRequest.swift
//  Vite
//
//  Created by Stone on 2018/10/25.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct GetPledgesRequest: JSONRPCKit.Request {
    public typealias Response = [Pledge]

    let address: String
    let index: Int
    let count: Int

    public var method: String {
        return "pledge_getPledgeList"
    }

    public var parameters: Any? {
        return [address, index, count]
    }

    public init(address: String, index: Int, count: Int) {
        self.address = address
        self.index = index
        self.count = count
    }

    public func response(from resultObject: Any) throws -> Response {
        guard let response = resultObject as? [String: Any] else {
            throw ViteError.JSONTypeError
        }

        var pledgeArray = [[String: Any]]()
        if let array = response["pledgeInfoList"] as?  [[String: Any]] {
            pledgeArray = array
        }

        let pledges = pledgeArray.map({ Pledge(JSON: $0) })
        let ret = pledges.compactMap { $0 }
        return ret
    }
}
