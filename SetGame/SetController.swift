//
//  ViewController.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SetController: UIViewController {
    
    private var setGame = SetGame() {
        didSet {
            let numberOfNewCards = setGame.dealtCards.count - oldValue.dealtCards.count
            addNewIndicesToButtonsAndCardsIndices(for: numberOfNewCards)
        }
    }
    lazy private var randomFreeButtonIndices = buttons.indices.map { $0 }.shuffled()
    
    @IBOutlet private var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGame.dealCards(.twelve)
        updateSetBoard()
    }
    
    private var buttonsAndCardIndices = [Int : Int]() {
        didSet {
            print(buttonsAndCardIndices)
        }
    }
    
}

extension SetController {
    private func addNewIndicesToButtonsAndCardsIndices(for numberOfNewCards: Int) {
        let buttonIndices = randomFreeButtonIndices.prefix(numberOfNewCards)
        randomFreeButtonIndices.removeFirst(numberOfNewCards)
        let newCardsIndices = setGame.dealtCards.indices.map { $0 }.suffix(numberOfNewCards)
        let buttonIndicesAndNewCardsIndices = zip(buttonIndices, newCardsIndices)
        buttonsAndCardIndices.merge(buttonIndicesAndNewCardsIndices, uniquingKeysWith: { $1 })
    }
    private func updateSetBoard() {
        for buttonIndex in buttonsAndCardIndices.keys {
            let cardIndex = buttonsAndCardIndices[buttonIndex]!
            let card = setGame[cardIndex]
            let button = buttons[buttonIndex]
            updateButton(button, withCard: card)
        }
    }
    private func updateButton(_ button: UIButton, withCard card: Card) {
        let singleCardShape: String
        switch card.shape {
        case .diamond: singleCardShape = "▲"
        case .oval: singleCardShape = "●"
        case .squiggle: singleCardShape = "■"
        }
        let numberOfShapes: Int
        switch card.numberOfShapes {
        case .one: numberOfShapes = 1
        case .two: numberOfShapes = 2
        case .three: numberOfShapes = 3
        }
        let resultingShapeString = String(String(repeating: singleCardShape + "\n", count: numberOfShapes).dropLast(1))
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.setTitle(resultingShapeString, for: .normal)
    }
}
