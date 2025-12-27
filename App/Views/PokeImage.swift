//
//  PokeImage.swift
//  Dex
//
//  Created by Yan  on 25/12/2025.
//

import SwiftUI

struct PokeImage<ImageContent : View, PlaceHolderContent : View>: View{
    @StateObject var pokeItem: PokeItem
    let image: (Image) -> ImageContent
    let placeHolder: () -> PlaceHolderContent
    
    init(pokeItem: PokeItem,
         @ViewBuilder image: @escaping (Image) -> ImageContent,
         @ViewBuilder placeHolder: @escaping () -> PlaceHolderContent)
    {
        
        self._pokeItem = StateObject(wrappedValue: pokeItem)
        self.image = image
        self.placeHolder = placeHolder
    }
    
    var body: some View {
        if let data = pokeItem.favorite ? pokeItem.shinyRaw : nil {
            if let img = UIImage(data: data){
                image(Image(uiImage: img))
            }
        }
       else if let data = !pokeItem.favorite ? pokeItem.spriteRaw : nil {
            if let img = UIImage(data: data){
                image(Image(uiImage: img))
            }
        }
        else{
           
            AsyncImage(url: pokeItem.favorite ? pokeItem.shinyURL : pokeItem.spriteURL){
                phase in
                switch phase {
                case .empty:
                    self.placeHolder()
                case .success(let image):
                    self.image(image)
                case .failure(let error):
                    self.placeHolder()
                        .task {
                            print("Unable to load \(pokeItem.favorite ? "shiny" : "") view for \(String(describing: pokeItem.name)) error: \(error)")
                        }
                @unknown default:
                    EmptyView()
                }
            }
        }
        
    }
}

#Preview {
    PokeImage(pokeItem: PersistenceController.fetchItemForPreveiw(),
              image: {image in
        image
            .resizable()
            .scaledToFit()
            .scaledToFit()
            .frame(width: 200)
        
            
    },placeHolder: {
        ProgressView()
            .frame(width: 100,height: 100)
            .background(Color.red)
    })
        
}
