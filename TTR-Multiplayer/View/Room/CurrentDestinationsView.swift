//
//  CurrentDestinationsView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-11.
//

import SwiftUI

struct CurrentDestinationsView: View {
    @Binding var playerCurrentTickets : [GameDestinationCard]
    @State var compact : Bool = false
    var body: some View {
        VStack {
            Text("Total Points \(playerCurrentTickets.reduce(0) { $0 + $1.point })")
                .padding([.leading,.trailing], 40)
                .padding([.top,.bottom], compact ? 2 : 10)
                .font(.system(.headline))
                .background(.mint)
                .clipShape(.capsule)
                .padding(.top, compact ? 0 : 25)
                .padding(compact ? 0 : 5)
            
            Divider()
                .padding(compact ? 0 : 10)
            
            ScrollView{
                ForEach(playerCurrentTickets) { card in
                    HStack(alignment: .center, spacing: 0){
                        Spacer()
                        Text(card.origin)
                            .frame(width:120,alignment: .center)
                            .font(.system(compact ? .footnote : .body).weight(.semibold))
                            .multilineTextAlignment(.center)
                        VStack{
                            Text(String(card.point))
                                .frame(width: compact ? 20 : 30, height: compact ? 20 : 30)
                                .font(.system(compact ? .footnote : .title3).weight(.bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding( compact ? 0 : 6)
                        }
                        .background(.white)
                        .clipShape(.circle)
                        .padding(compact ? 2 : 5)
                        
                        Text(card.destination)
                            .frame(width:120,alignment: .center)
                            .font(.system(compact ? .footnote : .body).weight(.semibold))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(width: getScreenSize().width - 100)
                    .foregroundColor(.black)
                    .padding(compact ? 1 : 5)
                    .background(.orange)
                    .clipShape(.capsule)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: getScreenSize().width - 100, maxHeight: getScreenSize().height)
    }
}

#Preview {
    CurrentDestinationsView(
        playerCurrentTickets: .constant([
            GameDestinationCard(
                destination: Destination(
                    id: "0",
                    origin: "Salt Lake City",
                    destination: "San Francisco",
                    point: 9
                )
            ),
            GameDestinationCard(
                destination: Destination(
                    id: "1",
                    origin: "LA",
                    destination: "LA",
                    point: 20
                )
            ),
            GameDestinationCard(
                destination: Destination(
                    id: "2",
                    origin: "LA",
                    destination: "LA",
                    point: 11
                )
            ),
            GameDestinationCard(
                destination: Destination(
                    id: "3",
                    origin: "LA",
                    destination: "LA",
                    point: 19
                )
            ),
            GameDestinationCard(
                destination: Destination(
                    id: "4",
                    origin: "LA",
                    destination: "LA",
                    point: 5
                )
            ),
            GameDestinationCard(
                destination: Destination(
                    id: "5",
                    origin: "LA",
                    destination: "LA",
                    point: 10
                )
            )
        ])
    )
}
