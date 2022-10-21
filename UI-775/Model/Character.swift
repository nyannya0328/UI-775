//
//  Character.swift
//  UI-775
//
//  Created by nyannyan0328 on 2022/10/21.
//

import SwiftUI

struct Character: Identifiable {
   var id = UUID().uuidString
    var value : String
    var index : Int = 0
    var rect : CGRect = .zero
    var color : Color = .clear

    
}


