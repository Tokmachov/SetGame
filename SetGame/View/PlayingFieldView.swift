//
//  CardsView.swift
//  SetGame
//
//  Created by mac on 07/02/2020.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

class PlayingFieldView: UIView {
    var cardViews = [ShapeView]() {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            setNeedsLayout()
        }
    }
    weak var delegate: PlayingFieldDelegate?
    
    override func layoutSubviews() {
        var cellAspectRatio: CGFloat
        if bounds.width >= bounds.height {
            cellAspectRatio = 1.5
        } else {
            cellAspectRatio = 0.5
        }
        var grid = Grid(layout: .aspectRatio(cellAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        
        for (i, cardView) in cardViews.enumerated() {
            let frame = grid[i]!
            cardView.frame = frame
            addSubview(cardView)
        }
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGestureRecognizer()
    }
    private func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccured(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    subscript(index: Int) -> ShapeView {
        return cardViews[index]
    }
    @objc func tapOccured(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: self)
            for (i, view) in cardViews.enumerated() {
                if view.frame.contains(location) {
                    delegate?.didTap(self, cardAtIndex: i)
                }
            }
        }
    }
}

protocol PlayingFieldDelegate: AnyObject {
    func didTap(_ playingFieldView: PlayingFieldView, cardAtIndex index: Int)
}
