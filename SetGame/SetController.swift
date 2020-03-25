//
//  ViewController.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SetController: UIViewController, SetGameDelegate, GameTimerDelegate, ComputerPlayerDelegate, PlayingFieldDelegate {
    
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
        playingFieldView.delegate = self
        setGame.delegate = self
        setGame.computerPlayerDelegate = self
        gameTimer.delegate = self
        setGame.startNewGame()
    }
    //MARK: PlayingFieldViewDelegate
    func didTap(_ playingFieldView: PlayingFieldView, cardAtIndex index: Int) {
        setGame.choseCard(at: index)
    }
    //MARK: SetGameDelegate

    func didUpdateGame(_ setGame: SetGame) {
        updateCards(from: setGame)
        updateScoreLabel(withScore: setGame.userScore)
        showGameResult(setGame)
        giveUpButton.isEnabled = isGiveUpButtonEnabled(setGame.moveResult)
    }
    
    func didStartNewGame(_ setGame: SetGame) {
        updateCards(from: setGame)
        updateScoreLabel(withScore: setGame.userScore)
        updateComputerScoreLabel(withScore: setGame.computerScore)
        giveUpButton.isEnabled = isGiveUpButtonEnabled(setGame.moveResult)
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
    func didShuffleCards(_ setGame: SetGame) {
        updateCards(from: setGame)
        showGameResult(setGame)
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
    //MARK: Labels
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var playingFieldView: PlayingFieldView! {
        didSet {
            let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeOccurd(_:)))
            downSwipe.direction = .down
            playingFieldView.addGestureRecognizer(downSwipe)
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureOccured(_:)))
            playingFieldView.addGestureRecognizer(rotationGesture)
        }
    }
    
    @IBOutlet weak var giveUpButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTurnTimeLabel: UILabel!
    
    @IBOutlet weak var computerFaceLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    
    //MARK: Actions
    
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
    @objc func swipeOccurd(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended && isPossibleToDealThreeMoreCards(setGame) {
            setGame.dealThreeCards()
        }
    }
    @objc func rotationGestureOccured(_ sender: UIRotationGestureRecognizer) {
        if sender.state == .ended {
            setGame.shuffleCards()
        }
    }
}

extension SetController {
    private func updateCards(from game: SetGame) {
        var shapeViews = [ShapeView]()
        for card in game.dealtCards {
            let view = shapeView(for: card)
            shapeViews.append(view)
        }
        playingFieldView.cardViews = shapeViews
    }
    private func shapeView(for card: Card) -> ShapeView {
        let shapeView: ShapeView
        switch card.traitOne {
        case 1: shapeView = CardViewsFactoy.makeCardView(type: .diamond)
        case 2: shapeView = CardViewsFactoy.makeCardView(type: .oval)
        case 3: shapeView = CardViewsFactoy.makeCardView(type: .squiggle)
        default: shapeView = CardViewsFactoy.makeCardView(type: .squiggle)
        }
        shapeView.numberOfShapes = card.traitTwo
        switch card.traitThree {
        case 1: shapeView.shading = .filled
        case 2: shapeView.shading = .unfilled
        case 3: shapeView.shading = .stripped
        default: break
        }
        shapeView.color = ShapeView.ShapeColor(rawValue: card.traitFour)!
        shapeView.isSelected = card.isSelected
        return shapeView
    }
    
    private func isPossibleToDealThreeMoreCards(_ game: SetGame) -> Bool {
        return !game.deckOfCards.isEmpty
    }
    private func isGiveUpButtonEnabled(_ moveResult: SetGame.MoveResult) -> Bool {
        switch moveResult {
        case .matched: return false
        default: return true
        }
    }

    private func showGameResult(_ game: SetGame) {
        for view in playingFieldView.cardViews where view.isSelected {
            switch game.moveResult {
            case .matched: view.highlight = .green
            case .misMatched: view.highlight = .red
            case .inProcessOfMatching: view.highlight = .plain
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
        indices.forEach { playingFieldView[$0].highlight = .orange }
    }
}


