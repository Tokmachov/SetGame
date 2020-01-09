//
//  Set.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct SetGame {
    
    // Public API
    var delegate: SetGameDelegate!
    
    var deckOfUndealtCards = [Card]()
    
    var dealtCards = [Card]()
    
    subscript(cardIndex: Int) -> Card {
        return dealtCards[cardIndex]
    }
    
    var result: MatchState {
        switch  selectedCards.count {
        case 3: return areMatch(selectedCards) ? .matched : .misMatched
        default: return .inProcessOfMatching
        }
    }
    
    var score: Int = 0
    
    mutating func dealThreeCards() {
        if result == .matched {
            substituteMatchedCardsForNewOnesOrDeactivateThem()
            delegate.didUpdateDealtCards(self)
        } else {
            let cardsToDeal = deckOfUndealtCards.prefix(3)
            deckOfUndealtCards.removeFirst(3)
            dealtCards.append(contentsOf: cardsToDeal)
            let newCardsIndices = dealtCards.indices.suffix(3)
            delegate.didAddNewCards(self, newCardsIndices: newCardsIndices)
        }
    }

    mutating func choseCard(atIndex index: Int) {
        assert(dealtCards.indices.contains(index), "Index passed to SetGame.choseCard(atIndex:) is out of SetGame.dealtCards indeces range.")
        let card = dealtCards[index]
        switch (result, card.state) {
        case (_, .incative): break
        case (.inProcessOfMatching, .unselected): dealtCards[index].state = .selected
        case (.inProcessOfMatching,.selected): dealtCards[index].state = .unselected
        case (.misMatched, _):
            deselectAllCards()
            dealtCards[index].state = .selected
        case (.matched, _):
            substituteMatchedCardsForNewOnesOrDeactivateThem()
            if dealtCards[index].state == .unselected {
                dealtCards[index].state = .selected
            }
        }
        score = newScore()
        delegate.didUpdateDealtCards(self)
    }
    mutating func startNewGame() {
        dealtCards.removeAll()
        deckOfUndealtCards = CardsFactory.makeAllPossibleCardsInRandomOrder()
        let cardToDealAtTheBeginningOfGame = deckOfUndealtCards.prefix(12)
        dealtCards.append(contentsOf: cardToDealAtTheBeginningOfGame)
        deckOfUndealtCards.removeFirst(12)
        score = 0
        delegate.didStartNewGame(self)
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
 
    private var selectedCards: [Card] {
        return dealtCards.filter { $0.state == .selected }
    }
    private func areMatch(_ cards: [Card]) -> Bool {
//        let traitOneCount = Set(cards.map { $0.traitFour }).count
//        let traitTwoCount = Set(cards.map { $0.traitOne }).count
//        let traitThreeCount = Set(cards.map { $0.traitThree }).count
//        let traitFourCount = Set(cards.map { $0.traitTwo }).count
//        
//        let isSetByTraightOne = (traitOneCount == 3 || traitOneCount == 1)
//        let isSetByTraightTwo = (traitTwoCount == 3 || traitTwoCount == 1)
//        let isSetByTraightThree = (traitThreeCount == 3 || traitThreeCount == 1)
//        let isSetByTraightFour = (traitFourCount == 3 || traitFourCount == 1)
        return true//isSetByTraightOne && isSetByTraightTwo && isSetByTraightThree && isSetByTraightFour
    }
    private mutating func deselectAllCards() {
        for index in dealtCards.indices where dealtCards[index].state == .selected {
            dealtCards[index].state = .unselected
        }
    }
    private mutating func substituteMatchedCardsForNewOnesOrDeactivateThem() {
        for (i, card) in dealtCards.enumerated() where card.state == .selected {
            if let newCard = deckOfUndealtCards.popLast() {
                dealtCards[i] = newCard
            } else {
                dealtCards[i].state = .incative
            }
        }
    }
    private func newScore() -> Int {
        switch result {
        case .matched: return score + 1
        case .misMatched: return score - 1
        default: return score
        }
    }
}

protocol SetGameDelegate {
    func didStartNewGame(_ setGame: SetGame)
    func didAddNewCards(_ setGame: SetGame, newCardsIndices: Range<Int>)
    func didUpdateDealtCards(_ setGame: SetGame)
}

