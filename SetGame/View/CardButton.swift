//
//  CardButton.swift
//  SetGame
//
//  Created by mac on 20/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CardButton: UIButton {
    var cardDispayMode = CardDisplayMode.notDisplayed {
        didSet {
            switch cardDispayMode {
            case .notDisplayed: showNoCard()
            case let .isDisplayed(attributeString: str): showCard(attributedString: str)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                showAsSelected()
            } else {
                showAsDeselected()
            }
        }
    }
    var backgroundHighlight = BackgroundColor.plain {
        didSet {
            switch backgroundHighlight {
            case .plain: self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            case .green: self.backgroundColor = UIColor.green
            case .red: self.backgroundColor = UIColor.red
            }
        }
    }
    
    private func showNoCard() {
        self.layer.borderWidth = 0.0
        self.backgroundColor = UIColor.clear
        self.setAttributedTitle(nil, for: .normal)
    }
    private func showCard(attributedString: NSMutableAttributedString) {
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func showAsSelected() {
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.blue.cgColor
        self.titleLabel?.backgroundColor = UIColor.clear
    }
    private func showAsDeselected() {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
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
    enum  BackgroundColor {
        case plain, red, green
    }
    enum CardDisplayMode {
        case isDisplayed(attributeString: NSMutableAttributedString)
        case notDisplayed
    }
}
