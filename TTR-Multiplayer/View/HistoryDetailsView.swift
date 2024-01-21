//
//  HistoryDetailsView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryDetailsView: View {
    @State var history : History
    @StateObject var viewModel = HistoryDetailsViewModel()
    var body: some View {
        VStack{
            Spacer()
            VStack{
                Text("Room \(history.room.roomCode)")
                    .font(.system(.title3).weight(.bold))
                
                let datetime = Date(timeIntervalSince1970: history.room.createdDateTime)
                Text(datetime.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(.caption).weight(.regular))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .foregroundColor(.white)
            .frame(alignment: .center)
            .padding([.leading,.trailing],80)
            .padding([.top,.bottom], 10)
            .background(.indigo)
            .clipShape(.capsule)
            .padding([.top], 30)
            
            HStack {
                Spacer()
                let ranks = findTheWinner(playerTickets: history.playersTickets).sorted { $0.value > $1.value }
                ForEach (Array(ranks.enumerated()), id: \.1.key) { index, keyValue in
                    Button (action: {
                        withAnimation(.snappy) {
                            if let tickets = history.playersTickets[keyValue.key] {
                                viewModel.selectedPlayerTickets = tickets
                            }
                        }
                    }) {
                        VStack (spacing: 0) {
                            Image(uiImage: getImage(uid: keyValue.key))
                                .resizable()
                                .frame(width: 65 - CGFloat(index * 5), height: 65 - CGFloat(index * 5))
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            
                            HStack {
                                //Winner
                                if index == 0 {
                                    Image(systemName: "checkmark.diamond.fill")
                                        .aspectRatio(contentMode: .fit)
                                        .padding(0)
                                }
                                Text(String(keyValue.value))
                                    .offset(x:index == 0 ? -5 : 0)
                            }
                            .frame(minWidth:65 - CGFloat(index * 5))
                            .font(.system(size:CGFloat(17 - index)).weight(.bold))
                            .foregroundColor(.indigo)
                            .background(.white)
                            .clipShape(Capsule())
                            .padding(.top, 10 - CGFloat(index))
                        }
                    }
                    
                    if index + 1 != ranks.count {
                        Divider()
                            .padding([.top,.bottom])
                            .padding([.leading,.trailing], ranks.count > 3 ? 0 : 10)
                    }
                }
                Spacer()
            }
            .background(.indigo)
            .frame(width: getScreenSize().width - 50, alignment: .center)
            .frame(maxHeight:135)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(5)
            Spacer()
            if viewModel.selectedPlayerTickets.count > 0 {
                ScrollView {
                    CurrentDestinationsView(
                        playerCurrentTickets: $viewModel.selectedPlayerTickets,
                        compact: false
                    )
                    .padding()
                }
            }
            Spacer()
        }
    }
    
    private func findTheWinner(playerTickets : [String:[GameDestinationCard]]) -> [String:Int] {
        var result : [String:Int] = [:]
        for player in playerTickets {
            result[player.key] = player.value.reduce(0) { (r,p) in
                return r + p.point
            }
        }
        return result
    }
    
    private func getImage(uid: String) -> UIImage {
        var result = UIImage(imageLiteralResourceName: "User")
        guard let data = StorageService.instance.playerImageCache[uid] else {
            return result
        }
        
        if let UIImage = UIImage(data:data) {
            result = UIImage
        }
        
        return result
    }
}

#Preview {
    HistoryDetailsView(
        history: History(id: "1000",
                         room: Room(
                            id: "1",
                            ownerID: "1",
                            roomCode: "1",
                            capacity: 3,
                            inUsed: false,
                            winner: "",
                            createdDateTime: 1705779046.79571,
                            playersIDs: ["1","2"]
                         ),
                         playersPoints: [:],
                         playersTickets: {
                             [:]
                         }())
    )
}
