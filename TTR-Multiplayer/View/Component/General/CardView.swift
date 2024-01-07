//
//  CardView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-06.
//

import SwiftUI

struct Card: Identifiable {
    var id: Int
    var image: String
    var offset: CGFloat
    var title: String
}

struct CardView: View {
    
    @State var cards = [Card(id: 0, image: "User", offset: 0, title: "User 1"),
                        Card(id: 1, image: "User", offset: 0, title: "User 2"),
                        Card(id: 2, image: "User", offset: 0, title: "User 3")]
    
    @State var scrolled = 0
    var body: some View {
        ZStack {
            ForEach(cards.reversed()) { (card) in
                HStack {
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)){
                        Image(card.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: calcwidth(),
                                   height: (UIScreen.main.bounds.height / 1.8) -
                                   CGFloat(card.id - scrolled) * 50)
                            .cornerRadius(18)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(card.title)
                        }
                        .frame(width:calcwidth() - 40)
                        .padding(.leading)
                        .padding(.bottom)
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
                            if -value.translation.width > 180 && card.id != cards.last!.id {
                                cards[card.id].offset = -(calcwidth() + 60)
                                scrolled += 1
                            } else {
                                cards[card.id].offset = 0
                            }
                        } else {
                            //Restore cards
                            if card.id > 0 {
                                if value.translation.width > 180 {
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
    CardView()
}
