//
//  SeededRandomGenerator.swift
//  Scrabble
//
//  Created by Eric Johns on 6/24/25.
//

import GameplayKit

struct SeededRandomGenerator: RandomNumberGenerator {
    let seed: UInt64
    
    private var generator: GKMersenneTwisterRandomSource
    
    init(seed: UInt64? = nil) {
        if (seed != nil) {
            self.seed = seed!
            print("Using given seed: \(self.seed)")
        } else {
            self.seed = UInt64.random(in: 0..<UInt64.max)
            print("Generated new seed: \(self.seed)")
        }
        
        self.generator = GKMersenneTwisterRandomSource(seed: self.seed)
    }
    
    mutating func next() -> UInt64 {
        let high = UInt64(bitPattern: Int64(generator.nextInt()))
        let low = UInt64(bitPattern: Int64(generator.nextInt()))
        return (high << 32) | low
    }
}

