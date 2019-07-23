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

public extension Data {

    var contentTypeInUInt16: UInt16? {
        guard count >= 2 else { return nil }
        let high = UInt16(self[0])
        let low = UInt16(self[1])
        let num = (high << 8) + low
        return num
    }

    var contentType: AccountBlockDataContentType? {
        guard let num = contentTypeInUInt16,
            let type = AccountBlockDataContentType(rawValue: num) else { return nil }
        return type
    }

    var rawContent: Data? {
        guard count >= 2 else { return nil }
        return Data(self.dropFirst(2))
    }

    var toAccountBlockNote: String? {
        if contentType == .utf8string,
            let contentData = rawContent,
            let note = String(bytes: contentData, encoding: .utf8) {
            return note
        } else {
            return nil
        }
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

    public static func generateCustomData(header: UInt16, data: Data) -> Data {
        return Data(header.toBytes) + data
    }
}

extension String {
    public func utf8StringToAccountBlockData() -> Data? {
        if isEmpty {
            return nil
        } else {
            return AccountBlockDataFactory.generateUTF8StringData(string: self)
        }
    }
}
