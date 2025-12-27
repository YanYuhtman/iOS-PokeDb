//
//  PokeItem.swift
//  PokeDb
//
//  Created by Yan  on 27/12/2025.
//
//

import Foundation
import SwiftData

@Model
public class PokeItem {
    #Unique<PokeItem>([\.id])
    var attack: Int16 = 0
    var defence: Int16 = 0
    var favorite: Bool = false
    var hp: Int16 = 0
    public var id: Int16 = 0
    var name: String? = "Noname"
    var shinyRaw: Data?
    var shinyURL: URL?
    var specialAttack: Int16 = 0
    var specialDefense: Int16 = 0
    var speed: Int16 = 0
    var spriteRaw: Data?
    var spriteURL: URL?
    @Attribute(.transformable(by: "NSSecureUnarchiveFromDataTransformer")) var types: [String]?
    public init() {

    }
    
}
