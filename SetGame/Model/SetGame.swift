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
    
    private var deckOfCards = [Card]()
    
    // Public API
    weak var delegate: SetGameDelegate!
    weak var computerPlayerDelegate: ComputerPlayerDelegate!
    
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
    /**
    if 'moveResult' value is '.matched': 1) substitutes selected cards for ones taken from deckOfCards
    2) reports to 'delegate' that dealtCards were updated;
    otherwise: 1) removes three cards from 'deckOfCards' and adds them to dealtCards 2) reports indices of added cards to delegate.
    */
    mutating func dealThreeCards() {
        if moveResult == .matched {
            substituteMatchedCardsForNewOnesOrDeactivateThem()
            delegate.didUpdateGame(self)
        } else {
            moveCardsFromDeckToDealtCards(numberOfCards: 3)
            let newCardsIndices = dealtCards.indices.suffix(3)
            delegate.didAddNewCards(self, newCardsIndices: newCardsIndices)
        }
    }
    /**Substitutes selected cards for new ones in 'dealtCards' if 'moveResult' value is '.matched';
    manages cards selection;
    updates 'gameScore';
    reports to 'delegate' that changes are made to model by selection
    
     - Parameter index: index of card in 'dealtCards'
    */
    mutating func choseCard(at index: Int) {
        assert(dealtCards.indices.contains(index), "Index passed to SetGame.choseCard(atIndex:) is out of SetGame.dealtCards indeces range.")
        if moveResult == .matched {
            substituteMatchedCardsForNewOnesOrDeactivateThem()
            delegate.didEndTurn(self)
            delegate.didStartTurn(self)
        }
        manageSelection(forCardAt: index)
        userScore = newScore()
        delegate.didUpdateGame(self)
        computerPlayerReaction(forMoveResut: self.moveResult)
    }
    
    /**Removes all cards from 'dealtcards';
    populates 'deckOfCards' with 81 new cards in random order;
    moves 12 cards from 'deckOfCards' to 'dealtCards';
    sets 'userScore' to 0;
    sets 'computerScore' to 0;
    reports end of turn to 'delegate';
    reports start of new game to 'delegate';
    reports start of new turn to 'delegate'. */
    mutating func startNewGame() {
        dealtCards.removeAll()
        deckOfCards = CardsFactory.makeAllPossibleCardsInRandomOrder()
        moveCardsFromDeckToDealtCards(numberOfCards: 12)
        userScore = 0
        computerScore = 0
        delegate.didEndTurn(self)
        delegate.didStartNewGame(self, newCardsIndices: dealtCards.indices)
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
    
    //MARK: Computer player methods
    
    /**Reports end of turn to 'delegate';
    deselects all cards;
    selects matched cards, reports cards update to 'delegate',
    increments 'computerScore', reports end of succesful move to 'computerPlayerDelegate',
    if matched cards indices were obtained;
    or reports end of unsuccesful move to 'computerDelegate'.*/
    mutating func letComputerMakeMove() {
        delegate.didEndTurn(self)
        deselectAllCards()
        if let indices = indicesOfThreeMatchedCards() {
            indices.forEach { dealtCards[$0].state = .selected }
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
        return dealtCards.filter { $0.state == .selected }
    }
    
    private mutating func manageSelection(forCardAt index: Int) {
        if selectedCards.count == 3 {
            deselectAllCards()
            
        }
        let cardState = dealtCards[index].state
        switch cardState {
        case .selected: dealtCards[index].state = .unselected
        case .unselected: dealtCards[index].state = .selected
        default: break
        }
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
        for index in dealtCards.indices where dealtCards[index].state == .selected {
            dealtCards[index].state = .unselected
        }
    }
    private mutating func substituteMatchedCardsForNewOnesOrDeactivateThem() {
        for (i, card) in dealtCards.enumerated() where card.state == .selected {
            if let newCard = deckOfCards.popLast() {
                dealtCards[i] = newCard
            } else {
                dealtCards[i].state = .incative
            }
        }
    }
    private mutating func moveCardsFromDeckToDealtCards(numberOfCards: Int) {
        guard !deckOfCards.isEmpty else { return }
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
        let activeCards = dealtCards.filter { $0.state != .incative }
        let cardCombos = kCombinations(k: 3, chosenFrom: activeCards)
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
    func didStartNewGame(_ setGame: SetGame, newCardsIndices: Range<Int>)
    func didAddNewCards(_ setGame: SetGame, newCardsIndices: Range<Int>)
    func didUpdateGame(_ setGame: SetGame)
    func didStartTurn(_ setGame: SetGame)
    func didEndTurn(_ setGame: SetGame)
}

protocol ComputerPlayerDelegate: AnyObject {
    func didReactOnCheating(_ computerPlayer: SetGame)
    func didReactOnMismatch(_ computerPlayer: SetGame)
    func didEndMove(_ computerPlayer: SetGame, withResult isSuccess: Bool)
    func didSayHello(_ computerPlayer: SetGame)
}
