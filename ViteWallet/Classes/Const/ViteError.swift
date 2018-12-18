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
    public let message: String
    public let rawError: Error?

    init(code: ViteErrorCode, message: String, rawError: Error?) {
        self.code = code
        self.message = "\(message)(\(code.toString()))"
        self.rawError = rawError
    }
}

extension ViteError {

    public static func conversion(from error: Error) -> ViteError {
        if let error = error as? APIKit.SessionTaskError {

            var rawError: NSError!
            var code = ViteErrorCode.unknown
            var message = ""

            switch error {
            case .connectionError(let e):
                rawError = (e as NSError)
                code = ViteErrorCode(type: .st_con, id: rawError.code)
                message = rawError.localizedDescription
            case .requestError(let e):
                rawError = (e as NSError)
                code = ViteErrorCode(type: .st_req, id: rawError.code)
                message = rawError.localizedDescription
            case .responseError(let e):
                if let rpcError = e as? JSONRPCError {
                    return conversionJSONRPCError(from: rpcError)
                } else {
                    rawError = (e as NSError)
                    code = ViteErrorCode(type: .st_res, id: rawError.code)
                    message = rawError.localizedDescription
                }
            }
            return ViteError(code: code, message: message, rawError: rawError)
        } else {
            return ViteError(code: ViteErrorCode(type: .unknown, id: (error as NSError).code), message: (error as NSError).localizedDescription, rawError: error)
        }
    }

    fileprivate static func conversionJSONRPCError(from error: JSONRPCError) -> ViteError {
        var rawError = (error as NSError)
        var code = ViteErrorCode.unknown
        var message = ""

        switch error {
        case .responseError(let c, let m, _):
            code = ViteErrorCode(type: .rpc, id: c)
            message = m
        case .responseNotFound:
            code = ViteErrorCode(type: .rpc_res_nf, id: 0)
            message = "responseNotFound"
        case .resultObjectParseError(let e):
            rawError = (e as NSError)
            code = ViteErrorCode(type: .rpc_ro_p, id: rawError.code)
            message = "resultObjectParseError \(rawError.localizedDescription)"
        case .errorObjectParseError(let e):
            rawError = (e as NSError)
            code = ViteErrorCode(type: .rpc_eo_p, id: rawError.code)
            message = "errorObjectParseError \(rawError.localizedDescription)"
        case .unsupportedVersion(let str):
            code = ViteErrorCode(type: .rpc_u_v, id: 0)
            message = "unsupportedVersion \(str ?? "")"
        case .unexpectedTypeObject:
            code = ViteErrorCode(type: .rpc_u_t, id: 0)
            message = "unexpectedTypeObject"
        case .missingBothResultAndError:
            code = ViteErrorCode(type: .rpc_m_re, id: 0)
            message = "missingBothResultAndError"
        case .nonArrayResponse:
            code = ViteErrorCode(type: .rpc_nar, id: 0)
            message = "nonArrayResponse"
        }

        return ViteError(code: code, message: message, rawError: rawError)
    }
}
