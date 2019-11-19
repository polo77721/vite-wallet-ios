//
//  AccountBlock.swift
//  Vite
//
//  Created by Stone on 2018/9/14.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ObjectMapper
import BigInt
import CryptoSwift
import Vite_HDWalletKit

public struct AccountBlock: Mappable {

    public struct Const {
        static let defaultHash = "0000000000000000000000000000000000000000000000000000000000000000"
    }

    public enum BlockType: Int {
        case createSend = 1
        case send = 2
        case rewardSend = 3
        case receive = 4
        case receiveError = 5
        case refundSend = 6
        case genesisReceive = 7
    }

    public fileprivate(set) var type: BlockType?
    public fileprivate(set) var hash: String?
    public fileprivate(set) var prevHash: String?
    public fileprivate(set) var accountAddress: ViteAddress?
    public fileprivate(set) var publicKey: String?
    public fileprivate(set) var fromAddress: ViteAddress?
    public fileprivate(set) var toAddress: ViteAddress?
    public fileprivate(set) var fromHash: String?
    public fileprivate(set) var tokenId: ViteTokenId?
    public fileprivate(set) var data: Data?
    public fileprivate(set) var timestamp: Int64?
    public fileprivate(set) var logHash: String?
    public fileprivate(set) var nonce: String?
    public fileprivate(set) var difficulty: BigInt?
    public fileprivate(set) var signature: String?
    public fileprivate(set) var height: UInt64?
    public fileprivate(set) var quota: UInt64?
    public fileprivate(set) var amount: Amount?
    public fileprivate(set) var fee: Amount?
    public fileprivate(set) var confirmedTimes: UInt64?
    public fileprivate(set) var token: Token?

    public init() {

    }

    public init?(map: Map) {
        guard let type = map.JSON["blockType"] as? Int, let _ = BlockType(rawValue: type) else {
            return nil
        }
    }

    public mutating func mapping(map: Map) {
        type <- map["blockType"]
        hash <- map["hash"]
        prevHash <- map["prevHash"]
        accountAddress <- map["accountAddress"]
        publicKey <- (map["publicKey"], JSONTransformer.hexToBase64)
        fromAddress <- map["fromAddress"]
        toAddress <- map["toAddress"]
        fromHash <- map["fromBlockHash"]
        tokenId <- map["tokenId"]
        data <- (map["data"], JSONTransformer.dataToBase64)
        timestamp <- map["timestamp"]
        logHash <- map["logHash"]
        nonce <- (map["nonce"], JSONTransformer.hexToBase64)
        difficulty <- (map["difficulty"], JSONTransformer.bigint)
        signature <- (map["signature"], JSONTransformer.hexToBase64)
        height <- (map["height"], JSONTransformer.uint64)
        quota <- (map["quota"], JSONTransformer.uint64)
        amount <- (map["amount"], JSONTransformer.balance)
        fee <- (map["fee"], JSONTransformer.balance)
        confirmedTimes <- (map["confirmedTimes"], JSONTransformer.uint64)
        token <- map["tokenInfo"]
    }
}

extension AccountBlock {

    public static func makeSendAccountBlock(secretKey: String,
                                            publicKey: String,
                                            address: ViteAddress,
                                            latest: AccountBlock?,
                                            toAddress: ViteAddress,
                                            tokenId: ViteTokenId,
                                            amount: Amount,
                                            fee: Amount?,
                                            data: Data?,
                                            nonce: String?,
                                            difficulty: BigInt?) -> AccountBlock {

        var block = makeBaseAccountBlock(secretKey: secretKey,
                                         publicKey: publicKey,
                                         address: address,
                                         latest: latest,
                                         nonce: nonce,
                                         difficulty: difficulty)

        block.type = .send
        block.toAddress = toAddress
        block.amount = amount
        block.tokenId = tokenId
        block.data = data
        block.fee = fee ?? Amount(0)

        let (hash, signature) = sign(accountBlock: block,
                                     secretKeyHexString: secretKey,
                                     publicKeyHexString: publicKey)
        block.hash = hash
        block.signature = signature

        return block
    }

    public static func makeReceiveAccountBlock(secretKey: String,
                                               publicKey: String,
                                               address: ViteAddress,
                                               onroadBlock: AccountBlock,
                                               latest: AccountBlock?,
                                               nonce: String?,
                                               difficulty: BigInt?) -> AccountBlock {

        var block = makeBaseAccountBlock(secretKey: secretKey,
                                         publicKey: publicKey,
                                         address: address,
                                         latest: latest,
                                         nonce: nonce,
                                         difficulty: difficulty)

        block.type = .receive
        block.fromHash = onroadBlock.hash

        let (hash, signature) = sign(accountBlock: block,
                                     secretKeyHexString: secretKey,
                                     publicKeyHexString: publicKey)
        block.hash = hash
        block.signature = signature

        return block
    }

    public static func merge(send: AccountBlock, to receive: AccountBlock) -> AccountBlock {
        var ret = receive
        ret.fromAddress = send.fromAddress
        ret.toAddress = send.toAddress
        ret.tokenId = send.tokenId
        ret.amount = send.amount
        ret.token = send.token
        return ret
    }

    fileprivate static func makeBaseAccountBlock(secretKey: String,
                                                 publicKey: String,
                                                 address: ViteAddress,
                                                 latest: AccountBlock?,
                                                 nonce: String?,
                                                 difficulty: BigInt?) -> AccountBlock {
        var block = AccountBlock()
        block.prevHash = latest?.hash ?? Const.defaultHash

        if let height = latest?.height {
            block.height = height + 1
        } else {
            block.height = 1
        }

        block.accountAddress = address

        block.fee = Amount(0)
        block.logHash = nil
        block.nonce = nonce
        block.difficulty = difficulty
        block.publicKey = publicKey

        return block
    }

    public static func sign(accountBlock: AccountBlock,
                             secretKeyHexString: String,
                             publicKeyHexString: String) -> (hash: String, signature: String) {
        var source = Bytes()

        if let type = accountBlock.type {
            let bytes = type.rawValue.toBytes
            source.append(contentsOf: [bytes.last!])
        }

        if let prevHash = accountBlock.prevHash {
            source.append(contentsOf: prevHash.hex2Bytes)
        }

        if let height = accountBlock.height {
            source.append(contentsOf: height.toBytes)
        }

        if let raw = accountBlock.accountAddress?.rawViteAddress {
            source.append(contentsOf: raw)
        }

        if let type = accountBlock.type {
            switch type {
            case .send:
                if let raw = accountBlock.toAddress?.rawViteAddress {
                    source.append(contentsOf: raw)
                }

                if let amount = accountBlock.amount {
                    let raw = [UInt8](BigUInt(amount).serialize())
                    source.append(contentsOf: raw.padding(toCount: 32))
                }

                if let raw = accountBlock.tokenId?.rawViteTokenId {
                    source.append(contentsOf: raw)
                }
            case .receive:
                if let fromHash = accountBlock.fromHash {
                    source.append(contentsOf: fromHash.hex2Bytes)
                }
            default:
                break
            }
        }

        // hash
        if let data = accountBlock.data {
            let hash = Blake2b.hash(outLength: 32, in: Bytes(data)) ?? Bytes()
            source.append(contentsOf: hash)
        }

        var feeBytes: Bytes = Bytes()
        if let fee = accountBlock.fee {
            feeBytes = [UInt8](BigUInt(fee).serialize())

        }
        feeBytes = feeBytes.padding(toCount: 32)
        source.append(contentsOf: feeBytes)

        if let logHash = accountBlock.logHash {
            source.append(contentsOf: logHash.hex2Bytes)
        }

        var nonceBytes: Bytes = Bytes()
        if let nonce = accountBlock.nonce {
            nonceBytes = nonce.hex2Bytes
        }
        nonceBytes = nonceBytes.padding(toCount: 8)
        source.append(contentsOf: nonceBytes)

        let hash = Blake2b.hash(outLength: 32, in: source) ?? Bytes()
        let hashString = hash.toHexString()
        let signature = Ed25519.sign(message: hash, secretKey: secretKeyHexString.hex2Bytes, publicKey: publicKeyHexString.hex2Bytes).toHexString()
        return (hashString, signature)
    }
}

extension FixedWidthInteger {
    public var toBytes: [UInt8] {
        var bigEndian = self.bigEndian
        let data = Data(bytes: &bigEndian, count: MemoryLayout.size(ofValue: bigEndian))
        let bytes = [UInt8](data)
        return bytes
    }
}

extension Array where Element == UInt8 {
    func padding(toCount newCount: Int, withPad pad: UInt8 = 0, isLeftPadding: Bool = true) -> Bytes {
        if count < newCount {
            return Bytes(repeating: pad, count: newCount - count) + self
        } else {
            return self
        }
    }
}

extension AccountBlock {
    public enum TransactionType: Int {
        case register
        case registerUpdate
        case cancelRegister
        case extractReward
        case vote
        case cancelVote
        case pledge
        case cancelPledge
        case coin
        case send
        case receive

        case registerSBP
        case voteForSBP
        case CancelSBPVoting
        case StakeForQuota
        case CancelQuotaStaking
    }

    public var transactionType: TransactionType {
        guard let type = type else {
            return .receive
        }

        switch type {
        case .createSend, .rewardSend, .refundSend:
            return .send
        case .receiveError, .genesisReceive:
            return .receive
        case .send:
            guard let hexString = data?.toHexString() else { return .send }
            guard hexString.count >= 8 else { return .send }
            let prefix = (hexString as NSString).substring(to: 8) as String
            if let type = AccountBlock.transactionTypeDataPrefixMap[prefix] {
                if AccountBlock.transactionTypeToAddressMap[type] == toAddress {
                    return type
                } else {
                    return .send
                }
            } else {
                return .send
            }
        case .receive:
            return .receive
        }
    }

    fileprivate static let transactionTypeDataPrefixMap: [String: TransactionType] = [
        //ABI.BuildIn.register.encodedFunctionSignature.toHexString(): .register,
        ABI.BuildIn.registerSBP.encodedFunctionSignature.toHexString(): .registerSBP,
        ABI.BuildIn.registerUpdate.encodedFunctionSignature.toHexString(): .registerUpdate,
        ABI.BuildIn.cancelRegister.encodedFunctionSignature.toHexString(): .cancelRegister,
        ABI.BuildIn.extractReward.encodedFunctionSignature.toHexString(): .extractReward,
        ABI.BuildIn.vote.encodedFunctionSignature.toHexString(): .vote,
        ABI.BuildIn.voteForSBP.encodedFunctionSignature.toHexString(): .voteForSBP,
        ABI.BuildIn.cancelVote.encodedFunctionSignature.toHexString(): .cancelVote,
        ABI.BuildIn.CancelSBPVoting.encodedFunctionSignature.toHexString(): .CancelSBPVoting,
        ABI.BuildIn.pledge.encodedFunctionSignature.toHexString(): .pledge,
        ABI.BuildIn.StakeForQuota.encodedFunctionSignature.toHexString(): .StakeForQuota,
        ABI.BuildIn.cancelPledge.encodedFunctionSignature.toHexString(): .cancelPledge,
        ABI.BuildIn.CancelQuotaStaking.encodedFunctionSignature.toHexString(): .CancelQuotaStaking,
        ABI.BuildIn.coinMint.encodedFunctionSignature.toHexString(): .coin,
    ]

    fileprivate static let transactionTypeToAddressMap: [TransactionType: String] = [
        //.register: ABI.BuildIn.register.toAddress,
        .registerSBP: ABI.BuildIn.registerSBP.toAddress,
        .registerUpdate: ABI.BuildIn.registerUpdate.toAddress,
        .cancelRegister: ABI.BuildIn.cancelRegister.toAddress,
        .extractReward: ABI.BuildIn.extractReward.toAddress,
        .vote: ABI.BuildIn.vote.toAddress,
        .voteForSBP: ABI.BuildIn.voteForSBP.toAddress,
        .cancelVote: ABI.BuildIn.cancelVote.toAddress,
        .CancelSBPVoting: ABI.BuildIn.CancelSBPVoting.toAddress,
        .pledge: ABI.BuildIn.pledge.toAddress,
        .StakeForQuota: ABI.BuildIn.StakeForQuota.toAddress,
        .cancelPledge: ABI.BuildIn.cancelPledge.toAddress,
        .CancelQuotaStaking: ABI.BuildIn.CancelQuotaStaking.toAddress,
        .coin: ABI.BuildIn.coinMint.toAddress,
    ]
}
