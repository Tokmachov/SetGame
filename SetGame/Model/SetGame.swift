//
//  Set.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation


struct SetGame {
    
    private var cards: [Card]
    private var maxCardsOnBoard: Int
    init(maxCardsOnBoard: Int) {
        self.maxCardsOnBoard = maxCardsOnBoard
        self.cards = CardsFactory.makeAllPossibleCardsInRandomOrder()
    }
    init(test: Bool) {
        self.maxCardsOnBoard = 24
        let card = Card(numberOfShapes: .one, shape: .diamond, shading: .solid, color: .green)
        self.cards = [card,card,card,card,card,card,card,card,card,card,card,card]
    }
    // Public API
    var dealtCards = [Card]()
    
    subscript(cardIndex: Int) -> Card {
        return dealtCards[cardIndex]
    }
    
    var matchState: MatchState {
        switch  numberOfSelectedCards {
        case 0...2: return .inProcessOfMatching
        case 3: return areMatch(selectedCards) ? .matched : .misMatched
        default: return .inProcessOfMatching
        }
    }
    
    var isAbleToDealCards: Bool {
        if (matchState == .inProcessOfMatching
            && cards.count >= NumberOfCardsDealt.duringTheGame.rawValue
            && dealtCards.count <= (maxCardsOnBoard - NumberOfCardsDealt.duringTheGame.rawValue))
            || cards.count >= NumberOfCardsDealt.duringTheGame.rawValue && (matchState == .matched) {
            return true
        } else {
            return false
        }
    }
    
    mutating func dealCards(_ numberOfCards: NumberOfCardsDealt) {
        if matchState == .matched {
            substituteMatchedCardsForNewOnesOrDeactivateThem()
        } else {
            let cardsToDeal = Array(cards.suffix(numberOfCards.rawValue))
            cards.removeLast(numberOfCards.rawValue)
            dealtCards.append(contentsOf: cardsToDeal)
        }
    }

    mutating func choseCard(atIndex index: Int) {
        assert(dealtCards.indices.contains(index), "Index passed to SetGame.choseCard(atIndex:) is out of SetGame.dealtCards indeces range.")
        let isSelected = dealtCards[index].isSelected
        switch (matchState, isSelected) {
        case (_, _) where dealtCards[index].isActive == false: break
        case (.inProcessOfMatching, false): dealtCards[index].isSelected = true
        case (.inProcessOfMatching, true): dealtCards[index].isSelected = false
        case (.misMatched, _):
            deselectAllCards()
            dealtCards[index].isSelected = true
        case (.matched, _):
            substituteMatchedCardsForNewOnesOrDeactivateThem()
            dealtCards[index].isSelected = true
        }
    }
}
extension SetGame {
    enum NumberOfCardsDealt: Int {
        case atTheBegining = 12, duringTheGame = 3
    }
}
extension SetGame {
    private struct CardsFactory {
        private static var randomColors = Card.Color.allCases
        private static var randomShadings = Card.Shading.allCases
        private static var randomNumberOfShapes = Card.NumberOfShapes.allCases
        private static var randomShapes = Card.Shape.allCases
        
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
            return cards.shuffled()
        }
    }
}
extension SetGame {
    enum MatchState {
        case matched, misMatched, inProcessOfMatching
    }
}

extension SetGame {
 
    private var numberOfSelectedCards: Int {
        return dealtCards.filter { $0.isSelected && $0.isActive }.count
    }
    private var selectedCards: [Card] {
        return dealtCards.filter { $0.isSelected && $0.isActive }
    }
    private func areMatch(_ cards: [Card]) -> Bool {
        let traitOneCount = Set(cards.map { $0.color }).count
        let traitTwoCount = Set(cards.map { $0.numberOfShapes }).count
        let traitThreeCount = Set(cards.map { $0.shading }).count
        let traitFourCount = Set(cards.map { $0.shape }).count
        
        let isSetByTraightOne = (traitOneCount == 3 || traitOneCount == 1)
        let isSetByTraightTwo = (traitTwoCount == 3 || traitTwoCount == 1)
        let isSetByTraightThree = (traitThreeCount == 3 || traitThreeCount == 1)
        let isSetByTraightFour = (traitFourCount == 3 || traitFourCount == 1)
        return isSetByTraightOne && isSetByTraightTwo && isSetByTraightThree && isSetByTraightFour
    }
    private mutating func deselectAllCards() {
        for index in dealtCards.indices {
            dealtCards[index].isSelected = false
        }
    }
    private mutating func substituteMatchedCardsForNewOnesOrDeactivateThem() {
        for (i, card) in dealtCards.enumerated() where card.isSelected {
            if let newCard = cards.popLast() {
                dealtCards[i] = newCard
            } else {
                dealtCards[i].isActive = false
            }
        }
    }
}
