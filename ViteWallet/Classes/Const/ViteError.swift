//
//  ViteError.swift
//  Vite
//
//  Created by haoshenyang on 2018/10/18.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit

public struct ViteError: Error {

    public let code: ViteErrorCode
    public let rawMessage: String
    public let rawError: Error?

    public init(code: ViteErrorCode, rawMessage: String, rawError: Error?) {
        self.code = code
        self.rawMessage = "\(rawMessage)(\(code.toString()))"
        self.rawError = rawError
    }
}

extension ViteError: Hashable {
    public static func == (lhs: ViteError, rhs: ViteError) -> Bool {
        return lhs.code == rhs.code
    }

    public var hashValue: Int {
        return code.toString().hashValue
    }
}

extension ViteError {

    public static func conversion(from error: Error) -> ViteError {
        if let error = error as? ViteError {
            return error
        } else if let error = error as? APIKit.SessionTaskError {

            var rawError: NSError!
            var code = ViteErrorCode(type: .custom, id: 0)
            var rawMessage = ""

            switch error {
            case .connectionError(let e):
                rawError = (e as NSError)
                code = ViteErrorCode(type: .st_con, id: rawError.code)
                rawMessage = rawError.localizedDescription
            case .requestError(let e):
                rawError = (e as NSError)
                code = ViteErrorCode(type: .st_req, id: rawError.code)
                rawMessage = rawError.localizedDescription
            case .responseError(let e):
                if let rpcError = e as? JSONRPCError {
                    return conversionJSONRPCError(from: rpcError)
                } else {
                    rawError = (e as NSError)
                    code = ViteErrorCode(type: .st_res, id: rawError.code)
                    rawMessage = rawError.localizedDescription
                }
            }
            return ViteError(code: code, rawMessage: rawMessage, rawError: rawError)
        } else {
            return ViteError(code: ViteErrorCode(type: .custom, id: (error as NSError).code), rawMessage: (error as NSError).localizedDescription, rawError: error)
        }
    }

    fileprivate static func conversionJSONRPCError(from error: JSONRPCError) -> ViteError {
        var rawError = (error as NSError)
        var code = ViteErrorCode(type: .custom, id: 0)
        var rawMessage = ""

        switch error {
        case .responseError(let c, let m, _):
            code = ViteErrorCode(type: .rpc, id: c)
            rawMessage = m
        case .responseNotFound:
            code = ViteErrorCode(type: .rpc_res_nf, id: 0)
            rawMessage = "responseNotFound"
        case .resultObjectParseError(let e):
            rawError = (e as NSError)
            code = ViteErrorCode(type: .rpc_ro_p, id: rawError.code)
            rawMessage = "resultObjectParseError \(rawError.localizedDescription)"
        case .errorObjectParseError(let e):
            rawError = (e as NSError)
            code = ViteErrorCode(type: .rpc_eo_p, id: rawError.code)
            rawMessage = "errorObjectParseError \(rawError.localizedDescription)"
        case .unsupportedVersion(let str):
            code = ViteErrorCode(type: .rpc_u_v, id: 0)
            rawMessage = "unsupportedVersion \(str ?? "")"
        case .unexpectedTypeObject:
            code = ViteErrorCode(type: .rpc_u_t, id: 0)
            rawMessage = "unexpectedTypeObject"
        case .missingBothResultAndError:
            code = ViteErrorCode(type: .rpc_m_re, id: 0)
            rawMessage = "missingBothResultAndError"
        case .nonArrayResponse:
            code = ViteErrorCode(type: .rpc_nar, id: 0)
            rawMessage = "nonArrayResponse"
        }

        return ViteError(code: code, rawMessage: rawMessage, rawError: rawError)
    }
}
