//
//  Card.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct Card {
    var numberOfShapes: NumberOfShapes
    var shape: Shape
    var shading: Shading
    var color: Color
    enum NumberOfShapes: CaseIterable {
        case one, two, three
    }
    enum Shape: CaseIterable {
        case diamond, squiggle, oval
    }
    enum Shading: CaseIterable {
        case solid, striped, open
    }
    enum Color: CaseIterable {
        case red, green, purple
    }
}
