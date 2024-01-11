//
//  CurrentDestinationsView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-11.
//

import SwiftUI

struct CurrentDestinationsView: View {
    @State var playerCurrentTickets : [GameDestinationCard] = []
    var body: some View {
        VStack{
            Text("Total Points \(playerCurrentTickets.reduce(0) { $0 + $1.point })")
                .padding([.leading,.trailing],40)
                .padding([.top,.bottom],10)
                .font(.system(.headline))
                .background(.teal)
                .clipShape(.capsule)
                .padding(.top,25)
                .padding(5)
            
            Divider()
                .padding()
            
            ScrollView{
                ForEach(playerCurrentTickets) { card in
                    HStack(alignment: .center, spacing: 0){
                        Spacer()
                        Text(card.origin)
                            .frame(width:100,alignment: .center)
                            .font(.system(.body).weight(.semibold))
                            .multilineTextAlignment(.center)
                        VStack{
                            Text(String(card.point))
                                .frame(width: 30, height: 30)
                                .font(.system(.title3).weight(.bold))
                                .foregroundColor(.indigo)
                                .multilineTextAlignment(.center)
                                .padding(6)
                        }
                        .background(.white)
                        .clipShape(.circle)
                        .padding(5)
                        
                        Text(card.destination)
                            .frame(width:100,alignment: .center)
                            .font(.system(.body).weight(.semibold))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(width: getScreenSize().width - 100)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(.indigo)
                    .clipShape(.capsule)
                    
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: getScreenSize().width - 100, maxHeight: getScreenSize().height)
    }
}

#Preview {
    CurrentDestinationsView(playerCurrentTickets: [
        GameDestinationCard(destination: Destination(id: "0", origin: "Salt Lake City", destination: "San Francisco", point: 9)),
        GameDestinationCard(destination: Destination(id: "1", origin: "LA", destination: "LA", point: 20)),
        GameDestinationCard(destination: Destination(id: "2", origin: "LA", destination: "LA", point: 11)),
        GameDestinationCard(destination: Destination(id: "3", origin: "LA", destination: "LA", point: 19)),
        GameDestinationCard(destination: Destination(id: "4", origin: "LA", destination: "LA", point: 5)),
        GameDestinationCard(destination: Destination(id: "5", origin: "LA", destination: "LA", point: 10))
    ])
}
