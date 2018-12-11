//
//  GetCancelVoteDataRequest.swift
//  Vite
//
//  Created by Water on 2018/11/6.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct GetCancelVoteDataRequest: JSONRPCKit.Request {
    public typealias Response = String

    let gid: String

    public var method: String {
        return "vote_getCancelVoteData"
    }

    public var parameters: Any? {
        return [gid]
    }

    public init(gid: String) {
        self.gid = gid
    }

    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw ViteError.JSONTypeError
        }
    }
}
