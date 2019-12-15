//
//  Card.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct Card {
    let numberOfShapes: NumberOfShapes
    let shape: Shape
    let shading: Shading
    let color: Color
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
