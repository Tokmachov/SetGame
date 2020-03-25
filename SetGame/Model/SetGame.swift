//
//  Set.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

/// Describes model of game Set.
struct SetGame {
    
    // Public API
    weak var delegate: SetGameDelegate!
    weak var computerPlayerDelegate: ComputerPlayerDelegate!
    
    var deckOfCards = [Card]()
    var dealtCards = [Card]()
    var moveResult: MoveResult {
        if selectedCards.count == 3 {
            return areMatch(selectedCards) ? .matched : .misMatched
        } else {
            return .inProcessOfMatching
        }
    }
    var userScore: Int = 0
    var computerScore: Int = 0
    var cheatCount = 0
    
    /// Accesses the "cardIndex"th card in "dealtCards"
       subscript(cardIndex: Int) -> Card {
           return dealtCards[cardIndex]
       }
    
    mutating func dealThreeCards() {
        assert(deckOfCards.count != 1 || dealtCards.count != 2, "Deck of cards has 1 or 2 cards. Impossible.")
        switch moveResult {
        case .matched where !deckOfCards.isEmpty: substituteThreeMatchedCardsForNewOnes()
        case .matched where deckOfCards.isEmpty: dealtCards.removeAll { $0.isSelected }
        case .misMatched where !deckOfCards.isEmpty: moveCardsFromDeckToDealtCards(numberOfCards: 3)
        case .inProcessOfMatching where !deckOfCards.isEmpty: moveCardsFromDeckToDealtCards(numberOfCards: 3)
        default: break
        }
        delegate.didUpdateGame(self)
    }
 
    mutating func choseCard(at index: Int) {
        if moveResult == .matched {
            if deckOfCards.count >= 3 {
                substituteThreeMatchedCardsForNewOnes()
            } else {
                dealtCards.removeAll { $0.isSelected }
            }
            delegate.didEndTurn(self)
            delegate.didStartTurn(self)
        }
        manageSelection(forCardAt: index)
        userScore = newScore()
        delegate.didUpdateGame(self)
        computerPlayerReaction(forMoveResut: self.moveResult)
    }
    
    mutating func startNewGame() {
        dealtCards.removeAll()
        deckOfCards = CardsFactory.makeAllPossibleCardsInRandomOrder()
        moveCardsFromDeckToDealtCards(numberOfCards: 12)
        userScore = 0
        computerScore = 0
        delegate.didEndTurn(self)
        delegate.didStartNewGame(self)
        delegate.didStartTurn(self)
    }
    
    /**Invokes cheating reaction method on 'computerPlayerDelegate';
    increments 'cheatCount';
    returns indices of cards that are match if they exist;
    returns nil otherwise.*/
    mutating func getIndicesOfThreeMatchedCards() -> [Int]? {
        computerPlayerDelegate.didReactOnCheating(self)
        cheatCount += 1
        guard let indices = indicesOfThreeMatchedCards() else { return nil }
        return indices
    }
    mutating func shuffleCards() {
        dealtCards.shuffle()
        delegate.didShuffleCards(self)
    }
    //MARK: Computer player methods

    mutating func letComputerMakeMove() {
        delegate.didEndTurn(self)
        deselectAllCards()
        if let indices = indicesOfThreeMatchedCards() {
            indices.forEach { dealtCards[$0].isSelected = true }
            delegate.didUpdateGame(self)
            computerScore += 1
            computerPlayerDelegate.didEndMove(self, withResult: true)
        } else {
            computerPlayerDelegate.didEndMove(self, withResult: false)
        }
        delegate.didStartTurn(self)
    }
    
    /// Makes self to send .didSayHello() to computerPlayerDelegate.
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
        return dealtCards.filter { $0.isSelected }
    }
    
    private mutating func manageSelection(forCardAt index: Int) {
        if selectedCards.count == 3 {
            deselectAllCards()
        }
        guard dealtCards.indices.contains(index) else { return }
        dealtCards[index].isSelected = !dealtCards[index].isSelected
    }
    /// Invokes methods of self.computerPlayerDelegate based on self.result.
    private func computerPlayerReaction(forMoveResut result: SetGame.MoveResult) {
        switch result {
        case .misMatched:
            computerPlayerDelegate.didReactOnMismatch(self)
        default: break
        }
    }
    
    /**
     Checks if three cards passed as argument are match according to Set game rules
     
     - Parameter cards: three cards that are to be checked if they are match.
     */
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
        for index in dealtCards.indices where dealtCards[index].isSelected {
            dealtCards[index].isSelected = false
        }
    }
    private mutating func substituteThreeMatchedCardsForNewOnes() {
        for (i, card) in dealtCards.enumerated() where card.isSelected {
            let newCard = deckOfCards.removeLast()
            dealtCards[i] = newCard
        }
    }

    private mutating func moveCardsFromDeckToDealtCards(numberOfCards: Int) {
        let cardsToDeal = deckOfCards.prefix(numberOfCards)
        deckOfCards.removeFirst(numberOfCards)
        dealtCards.append(contentsOf: cardsToDeal)
    }
    private func newScore() -> Int {
        switch moveResult {
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
        guard let cards = findThreeMatchedCards() else { return nil }
        let indices = indicesForCards(cards)
        return indices
    }
    private func findThreeMatchedCards() -> [Card]? {
        let cardCombos = kCombinations(k: 3, chosenFrom: dealtCards)
        for cardCombo in cardCombos {
            if areMatch(cardCombo) {
                return cardCombo
            }
        }
        return nil
    }
    private func indicesForCards(_ cards: [Card]) -> [Int] {
        var indices = [Int]()
        cards.forEach {
            if let index = dealtCards.firstIndex(of: $0) {
                indices.append(index)
            }
        }
        return indices
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
    func didStartNewGame(_ setGame: SetGame)
    func didUpdateGame(_ setGame: SetGame)
    func didStartTurn(_ setGame: SetGame)
    func didEndTurn(_ setGame: SetGame)
    func didShuffleCards(_ setGame: SetGame)
}

protocol ComputerPlayerDelegate: AnyObject {
    func didReactOnCheating(_ computerPlayer: SetGame)
    func didReactOnMismatch(_ computerPlayer: SetGame)
    func didEndMove(_ computerPlayer: SetGame, withResult isSuccess: Bool)
    func didSayHello(_ computerPlayer: SetGame)
}
