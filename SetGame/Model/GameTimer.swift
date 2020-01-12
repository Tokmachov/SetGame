//
//  GameTimer.swift
//  SetGame
//
//  Created by mac on 12/01/2020.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation

class GameTimer {
    private var movesTimer: Timer?
    weak var delegate: GameTimerDelegate?
    var isValid: Bool {
        guard let timer = movesTimer else { return false }
        return timer.isValid
    }
    func startGameTimer() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {[weak self] _ in
            guard let self = self else { return }
            self.delegate?.didFireOnHelloTime(self)
        }
    }
    func startMoveTimer() {
        movesTimer?.invalidate()
        movesTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            self.delegate?.didFireAfterOneSecondOfMove(self)
        }
        delegate?.didStartMoveTimer(self)
    }
    func stopMoveTimer() {
        movesTimer?.invalidate()
        delegate?.didStopMoveTimer(self)
    }
}

protocol GameTimerDelegate: AnyObject {
    func didFireAfterOneSecondOfMove(_ gameTimer: GameTimer)
    func didStartMoveTimer(_ gameTimer: GameTimer)
    func didStopMoveTimer(_ gameTimer: GameTimer)
    func didFireOnHelloTime(_ gameTimer: GameTimer)
}
