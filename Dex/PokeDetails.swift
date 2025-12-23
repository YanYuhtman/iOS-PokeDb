//
//  PokeDetails.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//

import SwiftUI
import Charts

func getBackground(type:String)-> ImageResource{
    return switch(type.lowercased()){
    case "grass","normal","electric","poison","fairy":
        ImageResource.normalgrasselectricpoisonfairy
    case "rock","ground","steel","flighting","ghost","dark","psychic":
        ImageResource.rockgroundsteelfightingghostdarkpsychic
    default:
        ImageResource.water
    }
}

struct PokeDetails: View {
    let pokeItem:PokeItem
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                
                Text(pokeItem.name!.capitalized)
                    .font(.title.bold())
                GeometryReader{gr in
                    ZStack{
                        Image(getBackground(type: pokeItem.types![0]))
                            .resizable()
                            .scaledToFit()
                            .frame(width: gr.size.width)
                        
                        AsyncImage(url: pokeItem.spriteURL) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: gr.size.width)
                            
                        } placeholder: {
                            ProgressView()
                                .frame(width: 100,height: 100)
                        }
                    }
                }.frame(height: 500)
                HStack{
                    ForEach(pokeItem.types!,id:\.self){type in
                        let color = Color(type.capitalized)
                        Text(type.capitalized)
                            .padding(5)
                            .padding(.leading,2)
                            .padding(.trailing,2)
                            .font(.title2)
                            .background(){
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(color)
                            }
                    }
                    Spacer()
                    Image(systemName: "star")
                        .resizable()
                        .foregroundColor(Color.yellow)
                        .scaledToFill()
                        .frame(width: 20)
                        
                }.padding()
                    .padding(.leading,0)
                    .padding(.trailing,10)
                
                VStack(alignment: .leading){
                    Text("Stats")
                        .font(.title.bold())
                    
                    withAnimation(.linear){
                        Stats(pokeItem: pokeItem)
                    }
                }.padding()

            }
            
        }
    }
}

struct ChartDataValue : Identifiable, Equatable{
    let id = UUID()
    let name: String
    let value: Int16
    let color: Color
    
    static func getStats(_ pokeItem: PokeItem)->[ChartDataValue]{
        return [
            ChartDataValue.init(name: "HP", value: pokeItem.hp, color: .fire),
            ChartDataValue.init(name: "Speed", value: pokeItem.speed, color: .dragon),
            ChartDataValue.init(name: "Attack", value: pokeItem.attack, color: .psychic),
            ChartDataValue.init(name: "SAtack", value: pokeItem.specialAttack, color: .psychic),
            ChartDataValue.init(name: "Defence", value: pokeItem.defence,color: .fighting),
            ChartDataValue.init(name: "SDefence", value: pokeItem.specialDefense, color: .fighting),
        ]
    }
    static func == (lhs: Self, rhs: Self) -> Bool{
        lhs.value == rhs.value
    }
}


struct Stats : View {
    let pokeItem: PokeItem
    var body: some View {
        Chart(ChartDataValue.getStats(pokeItem)){
            BarMark(x:.value("Value", $0.value) , y: .value("",$0.name))
                .foregroundStyle($0.color)
        }
        .chartLegend(.hidden)
        .chartXAxis{
            AxisMarks(values: [0,45,60,75,90,100])
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisTick()
                AxisValueLabel()
                // do NOT include AxisGridLine → removes horizontal lines
            }
        }
        .animation(.easeInOut(duration: 0.8), value: ChartDataValue.getStats(pokeItem))
        .foregroundColor(.bug)
        .frame(height: 200)
    }
}

#Preview {
    PokeDetails(pokeItem: PersistenceController.fetchItemForPreveiw())
}
#Preview {
    Stats(pokeItem: PersistenceController.fetchItemForPreveiw())
}
