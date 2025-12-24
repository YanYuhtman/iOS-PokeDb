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
    var hp:Int16 = 0
    var attack:Int16 = 0
    var defense:Int16 = 0
    var specialAttack:Int16 = 0
    var specialDefense:Int16 = 0
    var speed:Int16 = 0
    var spriteURL:URL
    var shinyURL:URL
    let types:[String]
    
    
    enum FirstLevelKeys: String, CodingKey{
        case id
        case name
        case stats
        case sprites
        case types
    }
    enum TypesLevelKeys : String, CodingKey{
        case type
        
        enum Keys : String, CodingKey{
            case name
        }
        
    }
    
    
    enum StatsLevelKeys:String, CodingKey{
        case stat
        case baseStat
        
        enum Keys : String, CodingKey{
            case name
        }
    }
    
    enum SpritesLevelKeys : String, CodingKey{
        case frontDefault
        case frontShiny
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: FirstLevelKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        //Get Types
        var _types:[String] = []
        var typesArray = try container.nestedUnkeyedContainer(forKey: .types)
        while !typesArray.isAtEnd{
            let typeLevelContainer = try typesArray.nestedContainer(keyedBy: TypesLevelKeys.self)
            let typeNameContainer = try typeLevelContainer.nestedContainer(keyedBy: TypesLevelKeys.Keys.self, forKey:.type)
            _types.append(try typeNameContainer.decode(String.self, forKey:.name))
                
        }
        self.types = _types
        
        //Get stats
        var statsArray = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsArray.isAtEnd{
            var statsElement = try statsArray.nestedContainer(keyedBy: StatsLevelKeys.self)
            let value = try statsElement.decodeIfPresent(Int16.self, forKey: .baseStat) ?? 0
            
            let innerEllement = try statsElement.nestedContainer(keyedBy: StatsLevelKeys.Keys.self, forKey:.stat)
            let name = try innerEllement.decode(String.self, forKey:StatsLevelKeys.Keys.name)
            print("Stat name: \(name), value: \(value)" )
            switch(name.lowercased()){
            case "hp":
                self.hp = value
            case "attack":
                attack = value
            case "defense":
                defense = value
            case "special-attack":
                specialAttack = value
            case "special-defense":
                specialDefense = value
            case "speed":
                speed = value
            default:
                print("Unsupported stat: \(name)")
                
            }
        }
        
        //Get Sprites
        let spritesElement = try container.nestedContainer(keyedBy: SpritesLevelKeys.self, forKey: .sprites)
        self.spriteURL = try spritesElement.decode(URL.self, forKey: .frontDefault)
        self.shinyURL = try spritesElement.decode(URL.self, forKey: .frontShiny)
        
        
    }
    
    
    
    
}
