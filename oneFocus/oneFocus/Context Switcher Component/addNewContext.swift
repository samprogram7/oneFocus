//
//  addNewContext.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/17/24.
//

import Foundation
import SwiftUI

struct contextCard {
    var title: String
    var workType: String
    var workDepth: String
    var notes: String
    
}

func makeContext(title: String, workType: String, workDepth: String, notes: String){
    contextCard(title: title, workType: workType, workDepth: workDepth, notes: notes)
    
}


