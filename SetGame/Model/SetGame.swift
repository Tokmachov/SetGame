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
        let card = Card(traitOne: .firstState, traitTwo: .secondState, traitThree: .thirdState, traitFour: .thirdState)
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
            && cards.count >= NumberOfCardsToDeal.duringTheGame.rawValue
            && dealtCards.count <= (maxCardsOnBoard - NumberOfCardsToDeal.duringTheGame.rawValue))
            || cards.count >= NumberOfCardsToDeal.duringTheGame.rawValue && (matchState == .matched) {
            return true
        } else {
            return false
        }
    }
    
    var score: Int = 0
    
    mutating func dealCards(_ numberOfCards: NumberOfCardsToDeal) {
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
        score = newScore()
    }
    mutating func startNewGame() {
        dealtCards.removeAll()
        cards = CardsFactory.makeAllPossibleCardsInRandomOrder()
        score = 0
    }
}
extension SetGame {
    enum NumberOfCardsToDeal: Int {
        case atGameBegining = 12, duringTheGame = 3
    }
}
extension SetGame {
    private struct CardsFactory {
        private static var firstTraitStates = Card.TraitState.allCases
        private static var secondTraitStates = Card.TraitState.allCases
        private static var thirdTraitStates = Card.TraitState.allCases
        private static var forthTraitStates = Card.TraitState.allCases
        
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
        let traitOneCount = Set(cards.map { $0.traitFour }).count
        let traitTwoCount = Set(cards.map { $0.traitOne }).count
        let traitThreeCount = Set(cards.map { $0.traitThree }).count
        let traitFourCount = Set(cards.map { $0.traitTwo }).count
        
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
    private func newScore() -> Int {
        switch matchState {
        case .matched: return score + 1
        case .misMatched: return score - 1
        default: return score
        }
    }
}
