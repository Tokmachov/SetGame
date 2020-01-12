//
//  Card.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct Card {
    let traitOne: Int
    let traitTwo: Int
    let traitThree: Int
    let traitFour: Int
    
    var state = CardState.unselected
    
    enum CardState {
        case selected, unselected, incative
    }
}

extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.traitOne == rhs.traitOne &&
            lhs.traitTwo == rhs.traitTwo &&
            lhs.traitThree == rhs.traitThree &&
            lhs.traitFour == rhs.traitFour
    }
}
