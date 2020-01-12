//
//  CardsFactory.swift
//  SetGame
//
//  Created by mac on 12/01/2020.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
extension SetGame {
    struct CardsFactory {
        private static var firstTraitStates = [1,2,3]
        private static var secondTraitStates = [1,2,3]
        private static var thirdTraitStates = [1,2,3]
        private static var forthTraitStates = [1,2,3]
        
        static func makeAllPossibleCardsInRandomOrder() ->[Card] {
            var cards = [Card]()
            for firstTraitState in firstTraitStates {
                for secondTraitState in secondTraitStates {
                    for thirdTraitState in thirdTraitStates {
                        for forthTraitState in forthTraitStates {
                            let card = Card(
                                traitOne: firstTraitState,
                                traitTwo: secondTraitState,
                                traitThree: thirdTraitState,
                                traitFour: forthTraitState
                            )
                            cards.append(card)
                        }
                    }
                }
            }
            return cards.shuffled()
        }
    }
}
