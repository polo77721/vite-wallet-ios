//
//  ViteWalletConst.swift
//  Vite
//
//  Created by Stone on 2018/11/20.
//  Copyright © 2018 vite labs. All rights reserved.
//

import Foundation
import BigInt

public struct ViteWalletConst {
    
    public enum ContractAddress: String {
        case register = "vite_0000000000000000000000000000000000000001c9e9f25417"
        case vote = "vite_000000000000000000000000000000000000000270a48cc491"
        case pledge = "vite_000000000000000000000000000000000000000309508ba646"
        case consensus = "vite_00000000000000000000000000000000000000042d7ef71894"
        case coin = "vite_00000000000000000000000000000000000000056ad6d26692"

        public var address: Address {
            return Address(string: self.rawValue)
        }
    }

    public enum ConsensusGroup: String {
        case `private` = "00000000000000000000"
        case snapshot = "00000000000000000001"
        case delegate = "00000000000000000002"

        public var id: String {
            return self.rawValue
        }
    }

    public static let viteToken = Token(id: "tti_5649544520544f4b454e6e40", name: "vite", symbol: "VITE", decimals: 18)
}
