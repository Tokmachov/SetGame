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
    var showsCad = false {
        didSet {
            if showsCad {
                makeVisible()
            } else {
                makeInvisible()
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
    private func makeVisible() {
        self.backgroundColor = backgroundColorForVisibleState
    }
    private func makeInvisible() {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = UIColor.clear
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
        showsCad = false
    }
}
