//
//  ViewController.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SetController: UIViewController, SetGameDelegate {

    private var setGame = SetGame()
    
    func didAddNewCards(_ setGame: SetGame, newCardsIndices: Range<Int>) {
        updateButtonsAndCardIndices(withNewCardsIndices: newCardsIndices)
        updateButtons(buttons, withCards: setGame.dealtCards)
        dealButton.isEnabled = isDealButtonEnabled(setGame)
    }
    
    func didUpdateDealtCards(_ setGame: SetGame) {
        updateButtons(buttons, withCards: setGame.dealtCards)
        showGameResult(setGame)
        updateScoreLabel(withScore: setGame.score)
        dealButton.isEnabled = isDealButtonEnabled(setGame)
    }
    
    func didStartNewGame(_ setGame: SetGame) {
        replaceButtonsAndCardIndices(withNewCardsIndices: setGame.dealtCards.indices)
        updateButtons(buttons, withCards: setGame.dealtCards)
        updateScoreLabel(withScore: setGame.score)
        dealButton.isEnabled = isDealButtonEnabled(setGame)
    }
    
    @IBOutlet private var buttons: [CardButton]!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var buttonsAndCardsIndices = [Int : Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGame.delegate = self
        setGame.startNewGame()
    }
    
    @IBAction func dealThreeMoreCardsIsPressed() {
        setGame.dealThreeCards()
    }
    
    @IBAction func cardButtonIsPressed(_ sender: CardButton) {
        if let buttonIndex = buttons.firstIndex(of: sender),
            let cardIndex = buttonsAndCardsIndices[buttonIndex] {
            setGame.choseCard(atIndex: cardIndex)
        }
    }
    
    @IBAction func newGameButtonIsPressed() {
        setGame.startNewGame()
    }
}

extension SetController {
    private func isDealButtonEnabled(_ game: SetGame) -> Bool {
        if game.result != .matched {
            return game.dealtCards.count < buttons.count
        } else {
            return game.deckOfUndealtCards.count > 0
        }
    }
    private func updateButtonsAndCardIndices(withNewCardsIndices indices: Range<Int>) {
        let freeButtonIndicesShuffled = Set(buttons.indices).subtracting(buttonsAndCardsIndices.keys).shuffled()
        let newButtonsIndices = freeButtonIndicesShuffled.prefix(indices.count)
        let buttonsAndCardIndices = zip(newButtonsIndices, indices)
        buttonsAndCardsIndices.merge(buttonsAndCardIndices, uniquingKeysWith: { $1 })
    }
    private func replaceButtonsAndCardIndices(withNewCardsIndices indices: Range<Int>) {
        buttonsAndCardsIndices = [:]
        let numberOfDealtCards = indices.count
        let buttonIndices = buttons.indices.shuffled().prefix(numberOfDealtCards)
        let buttonsAndCardIndices = zip(buttonIndices, indices)
        buttonsAndCardsIndices = Dictionary(uniqueKeysWithValues: buttonsAndCardIndices)
    }
    
    private func updateButtons(_ cardButtons: [CardButton], withCards cards: [Card]) {
          for (index, button) in cardButtons.enumerated() {
              if let cardIndex = buttonsAndCardsIndices[index] {
                  updateCardButton(button: button, withCard: cards[cardIndex])
              } else {
                  button.cardDispayMode = .noCard
              }
          }
      }
    
    private func updateCardButton(button: CardButton, withCard card: Card) {
        let str = makeAttributedString(forCard: card)
        switch card.state {
        case .incative:
            button.cardDispayMode = .inactive(attributeString: str)
        case .selected:
            button.cardDispayMode = .selected(attributeString: str)
        case .unselected:
            button.cardDispayMode = .unselected(attributeString: str)
        }
    }
    
    private func showGameResult(_ game: SetGame) {
        for (buttonIndex, button) in buttons.enumerated() {
            if let cardIndex = buttonsAndCardsIndices[buttonIndex], game[cardIndex].state == .selected {
                switch game.result {
                case .matched: button.backgroundHighlight = .green
                case .misMatched: button.backgroundHighlight = .red
                case .inProcessOfMatching: button.backgroundHighlight = .plain
                }
            }
        }
    }
    
    private func updateScoreLabel(withScore score: Int) {
          scoreLabel.text = "Score: \(score)"
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
    

}
