//
//  TestContent.swift
//  Dex
//
//  Created by Yan  on 25/12/2025.
//

import SwiftUI

//struct TestContent<Content:View>: View {
//    let image:some View = AnyView(EmptyView())
//    let placeholder:some View = AnyView(EmptyView())
//    public init<I, P>(@ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View{
//    
//        self.image = content(Image(systemName: "star.fill"))
//        self.placeholder = placeholder()
//    }
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//        image
//    }
//}

struct TestContent<ImageContent : View, PlaceHolderContent : View>: View {
    
    var image: (Image)-> ImageContent
    var placeholder:()-> PlaceHolderContent
    
    init(
        @ViewBuilder image: @escaping (Image) -> ImageContent,
        @ViewBuilder placeholder: @escaping () -> PlaceHolderContent) {
            self.image = image
            self.placeholder = placeholder
        }
        
    var body: some View {
        let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")
        AsyncImage(url: url!, content: {phase in
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                self.image(image)
            case .failure(let error):
                placeholder()
                    .task {
                        print("Unable to load \(error)")
                    }
            @unknown default:
                EmptyView()
            }
            
        })
    }
}
#Preview {
    TestContent(image: {image in
        image.resizable()
            .scaledToFill()
            .padding(20)
            .frame(minWidth: 300)
        
    }, placeholder: {
        EmptyView()
    })
}
