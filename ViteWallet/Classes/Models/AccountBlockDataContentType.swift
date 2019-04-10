//
//  AccountBlockDataContentType.swift
//  ViteWallet
//
//  Created by Stone on 2019/4/3.
//

import Vite_HDWalletKit

public enum AccountBlockDataContentType: UInt16 {
    case binary = 0x0001
    case utf8string = 0x0002

    public var header: Data {
        return Data(rawValue.toBytes)
    }
}

public extension Array where Element == UInt8 {
    var contentType: AccountBlockDataContentType? {

        guard count >= 2 else { return nil }

        let high = UInt16(self[0])
        let low = UInt16(self[1])
        let num = (high << 8) + low

        guard let type = AccountBlockDataContentType(rawValue: num) else { return nil }
        return type
    }
}

public struct AccountBlockDataFactory {
    public static func generateBinaryData(binary: Data) -> Data {
        return AccountBlockDataContentType.binary.header + binary
    }

    public static func generateUTF8StringData(string: String) -> Data? {
        guard let data = string.data(using: .utf8, allowLossyConversion: true) else { return nil }
        return AccountBlockDataContentType.utf8string.header + data
    }

    public static func generateCustomData(header: Data, data: Data) -> Data {
        return header + data
    }
}
