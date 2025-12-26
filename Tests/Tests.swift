//
//  DexTests.swift
//  DexTests
//
//  Created by Yan  on 23/12/2025.
//

import Testing
@testable import PokeDb

struct Tests {

    @Test func decode() async throws {
        await try PersistenceController.fetchPokeData(1)
    }

}
