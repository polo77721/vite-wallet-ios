//
//  ABI+BuildIn+Dex.swift
//  ViteWallet
//
//  Created by Stone on 2020/1/6.
//

import BigInt

extension ABI.BuildIn {

    public static func getDexDepositData() -> Data {
        return getData(type: .dexDeposit, values: [])
    }

    public static func getDexWithdrawData(tokenId: ViteTokenId, amount: Amount) -> Data {
        return getData(type: .dexWithdraw, values: [tokenId, amount.description])
    }

    public static func getDexBindInviterData(code: String) -> Data {
        return getData(type: .dexBindInviteCode, values: [code])
    }

    public static func getDexPlaceOrderData(tradeToken: ViteTokenId, quoteToken: ViteTokenId, isBuy: Bool, price: String, quantity: Amount) -> Data {
        return getData(type: .dexPlaceOrder, values: [tradeToken, quoteToken, isBuy ? "false" : "true", "0", price, quantity.description])
    }

    public static func getDexCancelOrderData(orderId: String) -> Data {
        return getData(type: .dexCancelOrder, values: [orderId])
    }

    public static func getDexStakeForVIP(isPledge: Bool) -> Data {
        return getData(type: .dexStakeForVIP, values: [isPledge ? "1": "2"])
    }
}
