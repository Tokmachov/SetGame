//
//  CardButton.swift
//  SetGame
//
//  Created by mac on 20/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CardButton: UIButton {
    var cardDispayMode = CardDisplayMode.noCard {
        didSet {
            switch cardDispayMode {
            case .noCard: showNoCard()
            case let .selected(attributeString: str): showSelected(str: str)
            case let .unselected(attributeString: str): showUnselected(str: str)
            case let .inactive(attributeString: str): showIncative(str: str)
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
    private func showSelected(str: NSMutableAttributedString) {
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.blue.cgColor
        self.titleLabel?.backgroundColor = UIColor.clear
        self.setAttributedTitle(str, for: .normal)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    }
    private func showUnselected(str: NSMutableAttributedString) {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.titleLabel?.backgroundColor = UIColor.clear
        self.setAttributedTitle(str, for: .normal)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    }
    private func showIncative(str: NSMutableAttributedString) {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.orange.cgColor
            self.titleLabel?.backgroundColor = UIColor.clear
            self.setAttributedTitle(str, for: .normal)
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
        case unselected(attributeString: NSMutableAttributedString)
        case selected(attributeString: NSMutableAttributedString)
        case inactive(attributeString: NSMutableAttributedString)
        case noCard
    }
}
