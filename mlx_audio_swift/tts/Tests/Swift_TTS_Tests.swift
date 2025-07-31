//
//  Swift_TTS_Tests.swift
//  Swift-TTS-Tests
//
//  Created by Ben Harraway on 14/04/2025.
//

import Testing

@testable import Swift_TTS

struct Swift_TTS_Tests {

    func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    func testViewBodyDoesNotCrash() {
        _ = ContentView().body
    }
    
    func testKokoro() async {
        let kokoroTTSModel = KokoroTTSModel()
        kokoroTTSModel.say("test", .bmGeorge)
    }
}
