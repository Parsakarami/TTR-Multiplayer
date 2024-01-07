//
//  DestinationPickerCardView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-07.
//

import SwiftUI

struct DestinationCardItem : Identifiable {
    var id: Int
    var origin: String
    var destination: String
    var point : Int
    var isSelected : Bool?
    var offset : CGFloat = 0
}

struct DestinationPickerCardView: View {
    @State var cards : [DestinationCardItem]
    @State var scrolled = 0
    var body: some View {
        ZStack {
            ForEach(cards.reversed()) { (card) in
                HStack {
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)){
                        VStack{
                            DestinationCardView(card:card)
                        }
                        .frame(width: calcwidth(),
                               height: (UIScreen.main.bounds.height / 1.8) -
                               CGFloat(card.id - scrolled) * 50)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .cornerRadius(18)
                        
                    }
                    .offset(x: card.id - scrolled <= 2 ? CGFloat(card.id - scrolled) * 30 : 60)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
                .offset(x: card.offset)
                .gesture(DragGesture().onChanged({value in
                    withAnimation{
                        //Disable last card drag
                        if value.translation.width < 0 && card.id != cards.last!.id {
                            cards[card.id].offset = value.translation.width
                        }else{
                            //Restoring cards
                            if card.id > 0 {
                                cards[card.id - 1].offset = -(calcwidth() + 60) + value.translation.width
                            }
                        }
                    }
                }).onEnded({ value in
                    withAnimation{
                        if value.translation.width < 0 {
                            if -value.translation.width > 120 && card.id != cards.last!.id {
                                cards[card.id].offset = -(calcwidth() + 60)
                                scrolled += 1
                            } else {
                                cards[card.id].offset = 0
                            }
                        } else {
                            //Restore cards
                            if card.id > 0 {
                                if value.translation.width > 120 {
                                    cards[card.id-1].offset = 0
                                    scrolled -= 1
                                } else {
                                    cards[card.id - 1].offset = -(calcwidth() + 60)
                                }
                            }
                        }
                    }
                }))
            }
        }
        .frame(height: UIScreen.main.bounds.height / 1.8)
        .padding(.horizontal,25)
        Spacer()
    }
    
    func calcwidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 50
        let width = screenWidth - (2 * 30)
        return width
    }
}

#Preview {
    
    DestinationPickerCardView(cards: [DestinationCardItem(id: 0, origin: "Los Angeles", destination: "New York", point: 21),DestinationCardItem(id: 1, origin: "Toronto", destination: "Denver", point: 18),DestinationCardItem(id: 2, origin: "Chicago", destination: "Las Vegas", point: 14)])
}
