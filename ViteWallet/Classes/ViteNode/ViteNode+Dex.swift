//
//  ViteNode+Dex.swift
//  ViteWallet
//
//  Created by Stone on 2019/9/9.
//

import APIKit
import JSONRPCKit
import PromiseKit
import BigInt

public extension ViteNode.dex {
    public struct info {}
    public struct perform {}
}

public extension ViteNode.dex.info {
    static func getDexBalanceInfos(address: ViteAddress, tokenId: ViteTokenId?) -> Promise<[DexBalanceInfo]> {
        return GetDexBalanceInfosRequest(address: address, tokenId: tokenId).defaultProviderPromise
    }

    static func getDexInviteCodeBinding(address: ViteAddress) -> Promise<Int64?> {
        return GetDexInviteCodeBindingRequest(address: address).defaultProviderPromise
    }

    static func checkDexInviteCode(inviteCode: Int64) -> Promise<Bool> {
        return CheckDexInviteCodeRequest(inviteCode: inviteCode).defaultProviderPromise
    }

    static func getDexVIPState(address: ViteAddress) -> Promise<Bool> {
        return GetDexVIPStateRequest(address: address).defaultProviderPromise
    }

    static func getDexVIPStakeInfoListRequest(address: ViteAddress, index: Int, count: Int) -> Promise<PledgeDetail> {
        return GetDexVIPStakeInfoListRequest(address: address, index: index, count: count).defaultProviderPromise
    }
}
