//
//  Set.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct SetGame {
    
    private var deckOfUndealtCards = [Card]()
    
    // Public API
    weak var delegate: SetGameDelegate!
    weak var computerPlayerDelegate: ComputerPlayerDelegate!
    
    var dealtCards = [Card]()
    
    subscript(cardIndex: Int) -> Card {
        return dealtCards[cardIndex]
    }
    
    var result: MoveResult {
        if selectedCards.count == 3 {
            return areMatch(selectedCards) ? .matched : .misMatched
        } else {
            return .inProcessOfMatching
        }
    }
    var userScore: Int = 0
    var computerScore: Int = 0
    var cheatCount = 0
    
    mutating func dealThreeCards() {
        if result == .matched {
            substituteMatchedCardsForNewOnesOrDeactivateThem()
            delegate.didUpdateDealtCards(self)
        } else {
            moveCardsFromDeckToDealtCards(numberOfCards: 3)
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
        userScore = newScore()
        delegate.didUpdateDealtCards(self)
        
        if result != .inProcessOfMatching {
            delegate.didEndTurn(self)
            delegate.didStartTurn(self)
        }
        if result == .misMatched {
            computerPlayerDelegate.didReactOnMismatch(self)
        }
    }
    mutating func startNewGame() {
        dealtCards.removeAll()
        deckOfUndealtCards = CardsFactory.makeAllPossibleCardsInRandomOrder()
        moveCardsFromDeckToDealtCards(numberOfCards: 12)
        userScore = 0
        computerScore = 0
        delegate.didEndTurn(self)
        delegate.didStartNewGame(self, newCardsIndices: dealtCards.indices)
        delegate.didStartTurn(self)
    }
    mutating func getIndicesOfThreeMatchedCards() -> [Int]? {
        computerPlayerDelegate.didReactOnCheating(self)
        cheatCount += 1
        let indices = indicesOfThreeMatchedCards()
        return indices
    }
    
    // Computer methods
    mutating func letComputerMakeMove() {
        delegate.didEndTurn(self)
        if let indices = indicesOfThreeMatchedCards() {
            deselectAllCards()
            indices.forEach { dealtCards[$0].state = .selected }
            delegate.didUpdateDealtCards(self)
            computerScore += 1
            computerPlayerDelegate.didEndMove(self, withResult: true)
        } else {
            computerPlayerDelegate.didEndMove(self, withResult: false)
        }
        delegate.didStartTurn(self)
    }
    func sayHello() {
        computerPlayerDelegate.didSayHello(self)
    }
}

extension SetGame {
    enum MoveResult {
        case matched, misMatched, inProcessOfMatching
    }
}

extension SetGame {
 
    private var selectedCards: [Card] {
        return dealtCards.filter { $0.state == .selected }
    }
    private func areMatch(_ cards: [Card]) -> Bool {
        let traitOneCount = Set(cards.map { $0.traitOne }).count
        let traitTwoCount = Set(cards.map { $0.traitTwo }).count
        let traitThreeCount = Set(cards.map { $0.traitThree }).count
        let traitFourCount = Set(cards.map { $0.traitFour }).count
        
        let isSetByTraightOne = (traitOneCount == 3 || traitOneCount == 1)
        let isSetByTraightTwo = (traitTwoCount == 3 || traitTwoCount == 1)
        let isSetByTraightThree = (traitThreeCount == 3 || traitThreeCount == 1)
        let isSetByTraightFour = (traitFourCount == 3 || traitFourCount == 1)
        return isSetByTraightOne && isSetByTraightTwo && isSetByTraightThree && isSetByTraightFour
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
    private mutating func moveCardsFromDeckToDealtCards(numberOfCards: Int) {
        let cardsToDeal = deckOfUndealtCards.prefix(numberOfCards)
        deckOfUndealtCards.removeFirst(numberOfCards)
        dealtCards.append(contentsOf: cardsToDeal)
    }
    private func newScore() -> Int {
        switch result {
        case .matched: return userScore + 1
        case .misMatched: return userScore - 1
        default: return userScore
        }
    }

    private func kCombinations<T: Equatable> (k: Int, chosenFrom elements: [T]) -> [[T]] {
        var outputCombinations = elements.map { [$0] }
        repeat {
            var temp = [[T]]()
            for el in outputCombinations {
                let startingElementOfElementsToFormCombinationsWith = el.last!
                let elemetsToFormCombinationsWith = [T](elements.drop { $0 != startingElementOfElementsToFormCombinationsWith }.dropFirst())
                guard !elemetsToFormCombinationsWith.isEmpty else { continue }
                temp += combinations(of: el, andElements: elemetsToFormCombinationsWith)
            }
            outputCombinations = temp
        } while outputCombinations.first!.count != k
        return outputCombinations
    }
    
    private func indicesOfThreeMatchedCards() -> [Int]? {
        let activeCards = dealtCards.filter { $0.state != .incative }
        let cardCombos = kCombinations(k: 3, chosenFrom: activeCards)
        for cardCombo in cardCombos {
            if areMatch(cardCombo) {
                var indices = [Int]()
                for card in cardCombo {
                    let index = dealtCards.firstIndex(of: card)!
                    indices.append(index)
                }
                return indices
            }
        }
        return nil
    }
    private func combinations<T: Equatable>(of initialCombination: [T], andElements elements: [T]) -> [[T]] {
        var output = [[T]]()
        for element in elements {
            let newCombination = initialCombination + [element]
            output.append(newCombination)
        }
        return output
    }
}

protocol SetGameDelegate: AnyObject {
    func didStartNewGame(_ setGame: SetGame, newCardsIndices: Range<Int>)
    func didAddNewCards(_ setGame: SetGame, newCardsIndices: Range<Int>)
    func didUpdateDealtCards(_ setGame: SetGame)
    func didStartTurn(_ setGame: SetGame)
    func didEndTurn(_ setGame: SetGame)
}

protocol ComputerPlayerDelegate: AnyObject {
    func didReactOnCheating(_ computerPlayer: SetGame)
    func didReactOnMismatch(_ computerPlayer: SetGame)
    func didEndMove(_ computerPlayer: SetGame, withResult isSuccess: Bool)
    func didSayHello(_ computerPlayer: SetGame)
}
