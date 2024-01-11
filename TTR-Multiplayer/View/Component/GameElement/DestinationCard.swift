//
//  DestinationCard.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-06.
//

import SwiftUI

//Add destination struct
struct DestinationCardView: View {
    @Binding var card : DestinationCardItem
    @State var isReadOnly : Bool = false
    @Binding var isSelected : Bool 
    var body: some View {
        ZStack (alignment: .center){
            VStack{
                HStack(alignment: .center, spacing: 0){
                    Spacer()
                    Text(card.origin)
                        .frame(width: 100,alignment: .trailing)
                        .font(.system(size: 15,weight: .bold,design: .serif))
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing,10)
                    VStack{
                        Text(String(card.point))
                            .font(.system(size: 20,weight: .heavy, design: .serif))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(6)
                    }
                    .padding(5)
                    .background(.white)
                    .clipShape(.circle)
                    
                    Text(card.destination)
                        .frame(width: 100,alignment: .leading)
                        .font(.system(size: 15,weight: .bold,design: .serif))
                        .multilineTextAlignment(.leading)
                        .padding(.leading,10)
                    Spacer()
                }
                .padding([.top,.bottom],15)
                .foregroundColor(.white)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(.blue)
                Spacer()
                if !isReadOnly {
                    Spacer()
                    VStack{
                        if let isSelected = card.isSelected {
                            Image(systemName: isSelected ? "checkmark" : "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 75,weight: .semibold))
                                .padding(40)
                                .background(isSelected ? .green : .red)
                                .clipShape(.circle)
                                .opacity(0.8)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                    }
                }
                Spacer()
                if !isReadOnly {
                    HStack{
                        if card.isSelected == nil || card.isSelected! {
                            Button(action:{
                                withAnimation(.snappy) {
                                    card.isSelected = false
                                }
                            }){
                                Image(systemName: "xmark")
                                    .font(.system(size: 23,weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: 50,maxHeight:50)
                            .background(.red)
                            .clipShape(.circle)
                            .shadow(radius: 8)
                            .padding(.leading, card.isSelected == nil ? 50 : 0)
                        }
                        
                        if(card.isSelected == nil) {
                            Spacer()
                        }
                        
                        if card.isSelected == nil || !card.isSelected! {
                            Button(action:{
                                withAnimation(.snappy) {
                                    card.isSelected = true
                                    isSelected = true
                                }
                            }){
                                Image(systemName: "checkmark")
                                    .font(.system(size: 23,weight: .bold))
                            }
                            .frame(maxWidth: 50,maxHeight:50)
                            .background(.green)
                            .clipShape(.circle)
                            .shadow(radius: 8)
                            .padding(.trailing,card.isSelected == nil ? 50 : 0)
                        }
                        
                    }
                    .padding()
                    .foregroundColor(.white)
                }
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        .background(Image("User").resizable().aspectRatio(contentMode: ContentMode.fill))
    }
}

//#Preview {
//    DestinationCardView(card: DestinationCardItem(id: 0,uniqueID: "2312323132132", origin: "New York", destination: "Seattle", point: 22),isSelected: .constant(false))
//}
