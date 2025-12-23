//
//  PokeTransferItem.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//

import Foundation

struct PokeTransportItem : Codable{
    let id:Int16
    let name:String
    
    //Types
    let types:[String]
    
    //Stats
    let hp:Int16
    let attack:Int16
    let defence:Int16
    let specialAttack:Int16
    let specialDefense:Int16
    let speed:Int16
    
    //Sprites
    let spriteURL:URL
    let shinyURL:URL
    
    enum FirstLevelKeys: String, CodingKey{
        case stats
        case sprites
        case types
    }
    enum TypesLevelKeys : String, CodingKey{
        case type
        
        enum TypeLevelKeys : String, CodingKey{
            case name
        }
        
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        let _types = try container.nestedContainer(keyedBy: TypesLevelKeys.self, forKey: .types)
        types = []
        
        self.hp = try container.decode(Int16.self, forKey: .hp)
        self.attack = try container.decode(Int16.self, forKey: .attack)
        self.defence = try container.decode(Int16.self, forKey: .defence)
        self.specialAttack = try container.decode(Int16.self, forKey: .specialAttack)
        self.specialDefense = try container.decode(Int16.self, forKey: .specialDefense)
        self.speed = try container.decode(Int16.self, forKey: .speed)
        
        self.spriteURL = try container.decode(URL.self, forKey: .spriteURL)
        self.shinyURL = try container.decode(URL.self, forKey: .shinyURL)
    }
    
    
    
    
}
