//
//  Card.swift
//  SetGame
//
//  Created by mac on 13/12/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct Card {
    let traitOne: TraitState
    let traitTwo: TraitState
    let traitThree: TraitState
    let traitFour: TraitState
    
    var isSelected = false
    var isActive = true
    enum TraitState:  Int, CaseIterable {
        case firstState = 1, secondState, thirdState
    }
}
