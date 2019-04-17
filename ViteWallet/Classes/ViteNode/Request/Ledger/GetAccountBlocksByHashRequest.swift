//
//  GetAccountBlocksByHashRequest.swift
//  Vite
//
//  Created by Stone on 2018/9/6.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct GetAccountBlocksByHashRequest: JSONRPCKit.Request {
    public typealias Response = (accountBlocks: [AccountBlock], nextHash: String?)

    let address: ViteAddress
    let hash: String?
    let count: Int

    public var method: String {
        return "ledger_getBlocksByHash"
    }

    public var parameters: Any? {
        if let hash = hash {
            return [address, hash, count + 1]
        } else {
            return [address, nil, count + 1]
        }
    }

    public init(address: ViteAddress, hash: String? = nil, count: Int) {
        self.address = address
        self.hash = hash
        self.count = count
    }

    public func response(from resultObject: Any) throws -> Response {
        var response = [[String: Any]]()
        if let object = resultObject as? [[String: Any]] {
            response = object
        }

        let transactions = response.map({ AccountBlock(JSON: $0) })
        let ret = transactions.compactMap { $0 }

        if ret.count > count {
            return (Array(ret.dropLast()), ret.last?.hash)
        } else {
            return (ret, nil)
        }
    }
}
