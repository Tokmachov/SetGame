//
//  ViewController.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SetController: UIViewController {
    
    private var setGame = SetGame(maxCardsOnBoard: 24) {
        didSet {
            updateButtonsAndCardsIndices()
            updateButtons()
            dealButton.isEnabled = setGame.isAbleToDealCards
            updateScoreLabel()
        }
    }
    
    @IBOutlet private var buttons: [CardButton]!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var buttonsAndCardsIndices = [Int : Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGame.dealCards(.atGameBegining)
    }
    
    @IBAction func dealThreeMoreCardsIsPressed() {
        setGame.dealCards(.duringTheGame)
    }
    @IBAction func cardButtonIsPressed(_ sender: CardButton) {
        if let buttonIndex = buttons.firstIndex(of: sender),
            let cardIndex = buttonsAndCardsIndices[buttonIndex] {
            setGame.choseCard(atIndex: cardIndex)
        }
    }
    @IBAction func newGameButtonIsPressed() {
        setGame.startNewGame()
        setGame.dealCards(.atGameBegining)
    }
}

extension SetController {
    private func updateButtonsAndCardsIndices() {
        let dealtCardsCount = setGame.dealtCards.count
        let numberOfCardsShownByButtons = buttonsAndCardsIndices.count
        let numberOfAddedCards = dealtCardsCount - numberOfCardsShownByButtons
        if dealtCardsCount == 0 {
            buttonsAndCardsIndices = [:]
        } else if numberOfAddedCards > 0 {
            let allButtonIndicesShuffled = Set(buttons.indices.shuffled())
            let buttonIndecesInUse = Set(buttonsAndCardsIndices.keys)
            let freeButtonIndices = allButtonIndicesShuffled.subtracting(buttonIndecesInUse)
            let buttonIndicesForNewCards = freeButtonIndices.suffix(numberOfAddedCards)
            let newCardsIndices = setGame.dealtCards.indices.map { $0 }.suffix(numberOfAddedCards)
            let buttonIndicesAndNewCardsIndices = zip(buttonIndicesForNewCards, newCardsIndices)
            buttonsAndCardsIndices.merge(buttonIndicesAndNewCardsIndices, uniquingKeysWith: { $1 })
        }
    }
    private func updateButtons() {
        for buttonIndex in 0..<buttons.count {
            if let cardIndex = buttonsAndCardsIndices[buttonIndex] {
                let card = setGame[cardIndex]
                let button = buttons[buttonIndex]
                updateButton(button, withCard: card)
            } else {
                buttons[buttonIndex].appearance = CardButton.Appearance.showsNoCard
            }
        }
        
    }
    
    private func updateButton(_ button: CardButton, withCard card: Card) {
        guard card.isActive else {
            button.appearance = .showsNoCard
            return
        }
        let attrString = makeAttributedString(forCard: card)
        button.setAttributedTitle(attrString, for: .normal)
        button.isPressed = card.isSelected
        if card.isSelected {
            button.appearance = cardButtonAppearance(fromGameState: setGame.matchState)
        } else {
            button.appearance = .showsCardInProcessOfMatching
        }
        
    }
    private func makeAttributedString(forCard card: Card) -> NSMutableAttributedString {
        let shapeString = produceShapeString(cardTraitOne: card.traitOne, cardTraitTwo: card.traitTwo)
        let attrString = NSMutableAttributedString(string: shapeString)
        let range = NSRange(location: 0, length: shapeString.count)
        let shadingAttribute = produceShadingAtribute(forCardTraitThree: card.traitThree)
        let colorAttribute = produceColorAttribute(cardTraitFour: card.traitFour, cardTraitThree: card.traitThree)
        let fontAttribute: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 18)]
        attrString.addAttributes(shadingAttribute, range: range)
        attrString.addAttributes(colorAttribute, range: range)
        attrString.addAttributes(fontAttribute, range: range)
        return attrString
    }
    private func produceShapeString(cardTraitOne: Card.TraitState, cardTraitTwo: Card.TraitState) -> String {
        let shapesCount: Int
        switch cardTraitOne {
        case .firstState: shapesCount = 1
        case .secondState: shapesCount = 2
        case .thirdState: shapesCount = 3
        }
        let shape: String
        switch cardTraitTwo {
        case .firstState: shape = "▲"
        case .secondState: shape = "●"
        case .thirdState: shape = "■"
        }
        let resultingShapeString = String(String(repeating: shape + "\n", count: shapesCount).dropLast(1))
        return resultingShapeString
    }
    private func produceShadingAtribute(forCardTraitThree trait: Card.TraitState) -> [NSAttributedString.Key : Any] {
        let attribute: [NSAttributedString.Key : Any]
        switch trait {
        case .firstState: attribute = [.strokeWidth : 6]
        case .secondState: attribute = [.strokeWidth : -0.5]
        case .thirdState: attribute = [.strokeWidth : -0.5]
        }
        return attribute
    }
    private func produceColorAttribute(cardTraitFour: Card.TraitState, cardTraitThree: Card.TraitState) -> [NSAttributedString.Key : Any] {
        var alpha: CGFloat = 1.0
        if cardTraitThree == .thirdState { alpha = 0.3 }
        let attribute: [NSAttributedString.Key : Any]
        switch cardTraitFour {
        case .firstState: attribute = [.foregroundColor :  #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).withAlphaComponent(alpha)]
        case .secondState: attribute = [.foregroundColor :  #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(alpha)]
        case .thirdState: attribute = [.foregroundColor :  #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(alpha)]
        }
        return attribute
    }
    private func cardButtonAppearance(fromGameState state: SetGame.MatchState) -> CardButton.Appearance {
        switch state {
        case .inProcessOfMatching: return .showsCardInProcessOfMatching
        case .matched: return .showsMatchedCard
        case .misMatched: return .showsMisMatchedCard
        }
    }
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(setGame.score)"
    }
}
