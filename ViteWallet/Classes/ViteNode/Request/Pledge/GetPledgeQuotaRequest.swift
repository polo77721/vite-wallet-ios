//
//  GetPledgeQuotaRequest.swift
//  Vite
//
//  Created by Stone on 2018/10/24.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct GetPledgeQuotaRequest: JSONRPCKit.Request {
    public typealias Response = Quota

    let address: ViteAddress

    public var method: String {
        return "pledge_getPledgeQuota"
    }

    public var parameters: Any? {
        return [address]
    }

    public init(address: ViteAddress) {
        self.address = address
    }

    public func response(from resultObject: Any) throws -> Response {

        guard let response = resultObject as? [String: Any] else {
            throw ViteError.JSONTypeError
        }

        if let quota = Quota(JSON: response) {
            return quota
        } else {
            throw ViteError.JSONTypeError
        }
    }
}
