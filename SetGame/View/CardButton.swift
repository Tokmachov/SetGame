//
//  CardButton.swift
//  SetGame
//
//  Created by mac on 20/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CardButton: UIButton {
    var isPressed = false {
        didSet {
            if isPressed {
                showAsSelected()
            } else {
                showAsDeselected()
            }
        }
    }
    var appearance: CardButton.Appearance = .showsCardInProcessOfMatching {
        didSet {
            switch appearance {
            case .showsNoCard: showNoCard()
            case .showsCardInProcessOfMatching: showCardInProcessOfMatching()
            case .showsMatchedCard: showMatchedCard()
            case .showsMisMatchedCard: showMisMatchedCard()
            }
        }
    }
    
    private var backgroundColorForVisibleState = UIColor.gray.withAlphaComponent(0.3)
    
    private func showAsSelected() {
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.blue.cgColor
    }
    private func showAsDeselected() {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    private func showNoCard() {
        self.layer.borderWidth = 0.0
        self.backgroundColor = UIColor.clear
        self.setAttributedTitle(nil, for: .normal)
    }
    private func showMatchedCard() {
        self.backgroundColor = UIColor.green
    }
    private func showMisMatchedCard() {
        self.backgroundColor = UIColor.red
    }
    private func showCardInProcessOfMatching() {
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    private func setupButton() {
        self.titleLabel?.numberOfLines = 0
        self.layer.cornerRadius = 8.0
        self.showNoCard()
    }
}
extension CardButton {
    enum Appearance {
        case showsNoCard, showsCardInProcessOfMatching, showsMatchedCard, showsMisMatchedCard
    }
}
