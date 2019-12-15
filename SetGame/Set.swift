//
//  Set.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct SetGame {
    var cards: [Card]
    init() {
        self.cards = CardsFactory.makeAllPossibleCardsInRandomOrder()
    }
}

extension SetGame {
    private struct CardsFactory {
        private static var randomColors = Card.Color.allCases.shuffled()
        private static var randomShadings = Card.Shading.allCases.shuffled()
        private static var randomNumberOfShapes = Card.NumberOfShapes.allCases.shuffled()
        private static var randomShapes = Card.Shape.allCases.shuffled()
        
        static func makeAllPossibleCardsInRandomOrder() ->[Card] {
            var cards = [Card]()
            for color in randomColors {
                for shading in randomShadings {
                    for numberOfShades in randomNumberOfShapes {
                        for shape in randomShapes {
                            let card = Card(
                                numberOfShapes: numberOfShades,
                                shape: shape,
                                shading: shading,
                                color: color
                            )
                            cards.append(card)
                        }
                    }
                }
            }
            return cards
        }
    }
}
