//
//  PokeListItem.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//
import CoreData
import SwiftUI

struct PokeListItem: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var pokeItem:PokeItem
//    @State private var favorite:Bool
//    init(pokeItem: PokeItem){
//        self.pokeItem = pokeItem
//        favorite = pokeItem.favorite
//    }
    var body: some View {
        HStack(){
            let url = pokeItem.favorite ? pokeItem.shinyURL : pokeItem.spriteURL
            let rawData = pokeItem.favorite ? pokeItem.spriteRaw : pokeItem.shinyRaw
            Group{
                if let data = rawData, let image = UIImage(data: data){
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(2.1)
                        .frame(width: 60)
                }else{
                    AsyncImage(url: url){image in
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(2.1)
                            .frame(width: 60)
                        
                    }placeholder: {
                        ProgressView()
                            .frame(width: 60,height: 60)
                    }
                }
            }.padding(.leading,10)
             .padding(.trailing, 60)
            
            HStack{
                VStack(alignment: .leading){
                    
                    Text(pokeItem.name!)
                        .font(.title3.bold())
                    HStack{
                        if let types = pokeItem.types{
                            ForEach(types,id:\.self){
                                type in
                                let color = Color(type.capitalized)
                                Text(type)
                                    .padding(.all,2)
                                    .padding(.leading,3)
                                    .padding(.trailing,3)
                                    .background(){
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(color)
                                    }
                            }
                        }
                    }
                    .padding(.trailing,10)
                }
            }
            Spacer()
            Image(systemName: pokeItem.favorite ? "star.fill" : "star")
                .resizable()
                .foregroundColor(Color.yellow)
                .scaledToFit()
                .frame(width: 20,height: 20)
                .padding(.trailing, 15)
        }
    }
}

#Preview {
    PokeListItem(pokeItem: PersistenceController.fetchItemForPreveiw())
}
