//
//  ViteNode+Transaction.swift
//  ViteWallet
//
//  Created by Stone on 2019/4/10.
//

import APIKit
import JSONRPCKit
import PromiseKit
import BigInt

public extension ViteNode.transaction {
    static func withoutPow(account: Wallet.Account,
                           toAddress: ViteAddress,
                           tokenId: ViteTokenId,
                           amount: Amount,
                           note: String?) -> Promise<AccountBlock> {

        var data: Data?
        if let note = note, !note.isEmpty {
            data = AccountBlockDataFactory.generateUTF8StringData(string: note)
        }
        return ViteNode.rawTx.send.withoutPow(account: account,
                                              toAddress: toAddress,
                                              tokenId: tokenId,
                                              amount: amount,
                                              fee: Amount(0),
                                              data:data)
    }

    static func getPow(account: Wallet.Account,
                       toAddress: ViteAddress,
                       tokenId: ViteTokenId,
                       amount: Amount,
                       note: String?) -> Promise<SendBlockContext> {
        var data: Data?
        if let note = note, !note.isEmpty {
            data = AccountBlockDataFactory.generateUTF8StringData(string: note)
        }
        return ViteNode.rawTx.send.getPow(account: account, toAddress: toAddress, tokenId: tokenId, amount: amount, fee: Amount(0), data: data)
    }
}
