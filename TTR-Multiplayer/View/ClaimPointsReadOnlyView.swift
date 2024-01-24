//
//  ClaimPointsReadOnlyView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-23.
//

import SwiftUI

struct ClaimPointsReadOnlyView: View {
    @State var playerPoint : PlayerPoint
    var body: some View {
        VStack {
            ScrollView {
                VStack (alignment:.center) {
                    Spacer()
                    
                    Text("Longest")
                        .font(.headline)
                        .frame(width:getScreenSize().width - 50 ,alignment: .leading)
                    
                    VStack{
                        HStack {
                            Text("Express ticket")
                            Spacer()
                            if playerPoint.isLongestPath {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundStyle(.green)
                                    .font(.title2)
                            } else {
                                Image(systemName: "xmark.square.fill")
                                    .foregroundStyle(.red)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    
                    Text("Trains")
                        .font(.headline)
                        .frame(width:getScreenSize().width - 50 ,alignment: .leading)
                        .padding(.top)
                    VStack {
                        generateTrainLabel(value: playerPoint.claimedTrains[1]!, number: 1)
                        generateTrainLabel(value: playerPoint.claimedTrains[2]!, number: 2)
                        generateTrainLabel(value: playerPoint.claimedTrains[3]!, number: 3)
                        generateTrainLabel(value: playerPoint.claimedTrains[4]!, number: 4)
                        generateTrainLabel(value: playerPoint.claimedTrains[5]!, number: 5)
                        generateTrainLabel(value: playerPoint.claimedTrains[6]!, number: 6)
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    
                    if playerPoint.allTickets.count > 0 {
                        Text("Tickets")
                            .font(.headline)
                            .frame(width:getScreenSize().width - 50 ,alignment: .leading)
                            .padding(.top)
                        
                        VStack{
                            ForEach (playerPoint.allTickets) { ticket in
                                
                                let bgColor = getClaimedTicketColor(ticketId: ticket.id)
                                HStack{
                                    Text("\(ticket.point)")
                                        .font(.system(.body).weight(.semibold))
                                        .frame(maxWidth: 22)
                                        .padding(.leading,15)
                                    
                                    Divider()
                                        .padding([.top,.bottom])
                                    
                                    Text("\(ticket.origin) - \(ticket.destination)")
                                        .font(.system(.callout).weight(.regular))
                                    Spacer()
                                }
                                .background(bgColor)
                                .frame(maxHeight: 55)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding([.leading,.trailing],3)
                                .padding([.top,.bottom],2)
                            }
                        }
                        .padding()
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    }
                    
                    Spacer()
                }
            }
        }
        .padding([.leading,.trailing], 20)
        .padding(.top,10)
        .background(.gray.opacity(0.15))
    }
    
    private func generateTrainLabel(value: Int, number: Int) -> some View {
        return HStack{
            generateTrains(number: number)
            Spacer()
            Text("\(value)")
                .padding(.trailing,10)
        }
    }
    
    private func generateTrains(number: Int) -> some View {
        return HStack (spacing: 0) {
            ForEach (0..<number, id: \.self) { index in
                Image(systemName: "train.side.middle.car")
            }
        }
    }
    
    private func getClaimedTicketColor(ticketId: String) -> Color {
        var color : Color = .gray
        
        if let key = playerPoint.claimedTickets.keys.first(where: {$0 == ticketId}) {
            if let value = playerPoint.claimedTickets[key] {
                color = value ? .green : .red
            }
        }
        
        return color
    }
}

#Preview {
    ClaimPointsReadOnlyView(playerPoint: PlayerPoint(playerId: "1"))
}
