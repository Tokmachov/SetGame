//
//  ViewController.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SetController: UIViewController, SetGameDelegate, GameTimerDelegate, ComputerPlayerDelegate {
  
    private var setGame = SetGame()
    private var gameTimer = GameTimer()
    
    private var timeSpentInTurn = 0 {
        didSet {
            currentTurnTimeLabel.text = "\(timeSpentInTurn)"
        }
    }
    private var totalTimeSpent = 0 {
        didSet {
            totalTimeLabel.text = "\(totalTimeSpent)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGame.delegate = self
        setGame.computerPlayerDelegate = self
        setGame.startNewGame()
        gameTimer.delegate = self
    }
    
    //MARK: SetGameDelegate
    func didAddNewCards(_ setGame: SetGame, newCardsIndices: Range<Int>) {
        updateButtonsAndCardIndices(withNewCardsIndices: newCardsIndices)
        updateCardButtons(withCards: setGame.dealtCards)
        dealButton.isEnabled = isDealButtonEnabled(setGame.result, numberOfDealtCards: setGame.dealtCards.count)
        giveUpButton.isEnabled = isGiveUpButtonEnabled(setGame.result)
    }
    
    func didUpdateDealtCards(_ setGame: SetGame) {
        updateCardButtons(withCards: setGame.dealtCards)
        showGameResult(setGame)
        updateScoreLabel(withScore: setGame.userScore)
        dealButton.isEnabled = isDealButtonEnabled(setGame.result, numberOfDealtCards: setGame.dealtCards.count)
        giveUpButton.isEnabled = isGiveUpButtonEnabled(setGame.result)
    }
    
    func didStartNewGame(_ setGame: SetGame, newCardsIndices: Range<Int>) {
        replaceButtonsAndCardIndices(withNewCardsIndices: newCardsIndices)
        updateCardButtons(withCards: setGame.dealtCards)
        updateScoreLabel(withScore: setGame.userScore)
        updateComputerScoreLabel(withScore: setGame.computerScore)
        dealButton.isEnabled = isDealButtonEnabled(setGame.result, numberOfDealtCards: setGame.dealtCards.count)
        giveUpButton.isEnabled = isGiveUpButtonEnabled(setGame.result)
        totalTimeSpent = 0
        gameTimer.startGameTimer()
    }
    
    func didStartTurn(_ setGame: SetGame) {
        gameTimer.startMoveTimer()
    }
    
    func didEndTurn(_ setGame: SetGame) {
        gameTimer.stopMoveTimer()
        totalTimeSpent += timeSpentInTurn
        timeSpentInTurn = 0
    }
    
    //MARK: GameTimerDelegate
    func didFireAfterOneSecondOfMove(_ gameTimer: GameTimer) {
        timeSpentInTurn += 1
    }
    
    func didStartMoveTimer(_ gameTimer: GameTimer) {
        timerButton.setTitle("Остановить таймер", for: .normal)
    }
    
    func didStopMoveTimer(_ gameTimer: GameTimer) {
        timerButton.setTitle("Запустить таймер", for: .normal)
    }
    func didFireOnHelloTime(_ gameTimer: GameTimer) {
        setGame.sayHello()
    }
    
    //MARK: ComputerPlayerDelegate
    func didReactOnCheating(_ computerPlayer: SetGame) {
        let emotions = "😕🤨😳😲😡🤬🤢🤮"
        let emotionIndex = emotions.index(emotions.startIndex, offsetBy: computerPlayer.cheatCount % emotions.count)
        computerFaceLabel.text = String(emotions[emotionIndex])
        updateComputerFaceTostandardEmotion()
    }
    func didReactOnMismatch(_ computerPlayer: SetGame) {
        computerFaceLabel.text = String("😂🤣😅".randomElement()!)
        updateComputerFaceTostandardEmotion()
    }

    func didEndMove(_ computerPlayer: SetGame, withResult isSuccess: Bool) {
        updateComputerScoreLabel(withScore: computerPlayer.computerScore)
        if isSuccess {
            computerFaceLabel.text = "🤓"
            updateComputerFaceTostandardEmotion()
        } else {
            computerFaceLabel.text = String("💩🙀🤷‍♀️🙈".randomElement()!)
            updateComputerFaceTostandardEmotion()
        }
    }
    func didSayHello(_ computerPlayer: SetGame) {
        computerFaceLabel.text = "🤗"
        updateComputerFaceTostandardEmotion()
    }
    private func updateComputerFaceTostandardEmotion() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.computerFaceLabel.text = "😀"
        }
    }
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK: Buttons labels
    @IBOutlet weak var giveUpButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet private var buttons: [CardButton]!
    
    //MARK: Timer labels
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTurnTimeLabel: UILabel!
    
    //MARK: Computer player labels
    @IBOutlet weak var computerFaceLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    
    
    private var buttonsAndCardsIndices = [Int : Int]()
    
    //MARK: Actions
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
    
    @IBAction func cheatButtonIsPressed() {
        guard let indices = setGame.getIndicesOfThreeMatchedCards() else {
            return
        }
        highlightCardsForCheating(withIndices: indices)
    }
    
    @IBAction func pauseTimerButtonIsPressed(_ sender: UIButton) {
        if gameTimer.isValid {
            gameTimer.stopMoveTimer()
        } else {
            gameTimer.startMoveTimer()
        }
    }
    @IBAction func giveUpButtonIsPressed(_ sender: UIButton) {
        setGame.letComputerMakeMove()
    }
}

extension SetController {
    private func isDealButtonEnabled(_ moveResult: SetGame.MoveResult, numberOfDealtCards: Int) -> Bool {
        switch moveResult {
        case .matched: return true
        default: return numberOfDealtCards < buttons.count
        }
    }
    private func isGiveUpButtonEnabled(_ moveResult: SetGame.MoveResult) -> Bool {
        switch moveResult {
        case .matched: return false
        default: return true
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
    
    private func updateCardButtons(withCards cards: [Card]) {
          for (index, button) in buttons.enumerated() {
              if let cardIndex = buttonsAndCardsIndices[index] {
                let card = cards[cardIndex]
                updateCardButton(button: button, withCard: card)
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
                case .matched: button.backgroundHighlight = .matched
                case .misMatched: button.backgroundHighlight = .mismatched
                case .inProcessOfMatching: button.backgroundHighlight = .plain
                }
            }
        }
    }
    
    private func updateScoreLabel(withScore score: Int) {
          scoreLabel.text = "\(score)"
    }
    private func updateComputerScoreLabel(withScore score: Int) {
        computerScoreLabel.text = "\(score)"
    }
    private func highlightCardsForCheating(withIndices indices: [Int]) {
        for (buttonIndex, button) in buttons.enumerated() {
            if let cardIndex = buttonsAndCardsIndices[buttonIndex], indices.contains(cardIndex) {
                button.backgroundHighlight = .highlightedForCheating
            }
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
    private func produceShapeString(cardTraitOne: Int, cardTraitTwo: Int) -> String {
        let shapesCount = cardTraitOne
        let shapes = ["▲", "●", "■"]
        assert([1,2,3].contains(cardTraitTwo), "Card.traitTwo value \(cardTraitTwo) is not suitable as index for shapes: \(shapes.indices)")
        let shape = shapes[cardTraitTwo - 1]
        let resultingShapeString = String(String(repeating: shape + "\n", count: shapesCount).dropLast(1))
        return resultingShapeString
    }
    private func produceShadingAtribute(forCardTraitThree trait: Int) -> [NSAttributedString.Key : Any] {
        let attribute: [NSAttributedString.Key : Any]
        assert((1...3).contains(trait), "Card.traightThree must be betwee 1 and 3 ")
        switch trait {
        case 1: attribute = [.strokeWidth : 6]
        case 2: attribute = [.strokeWidth : -0.5]
        case 3: attribute = [.strokeWidth : -0.5]
        default: attribute = [:]
        }
        return attribute
    }
    private func produceColorAttribute(cardTraitFour: Int, cardTraitThree: Int) -> [NSAttributedString.Key : Any] {
        assert((1...3).contains(cardTraitFour) && (1...3).contains(cardTraitFour), "Card.traightFour,Card.traightThree  must be betwee 1 and 3 ")
        var alpha: CGFloat = 1.0
        if cardTraitThree == 3 { alpha = 0.3 }
        let attribute: [NSAttributedString.Key : Any]
        switch cardTraitFour {
        case 1: attribute = [.foregroundColor :  #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).withAlphaComponent(alpha)]
        case 2: attribute = [.foregroundColor :  #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(alpha)]
        case 3: attribute = [.foregroundColor :  #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(alpha)]
        default: attribute = [:]
        }
        return attribute
    }
    

}
