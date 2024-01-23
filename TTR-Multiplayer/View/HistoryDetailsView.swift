//
//  HistoryDetailsView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryDetailsView: View {
    @State var history : Room
    @StateObject var viewModel = HistoryDetailsViewModel()
    var body: some View {
        VStack{
            Spacer()
            VStack{
                Text("Room \(history.roomCode)")
                    .font(.system(.title3).weight(.bold))
                
                let datetime = Date(timeIntervalSince1970: history.createdDateTime)
                Text(datetime.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(.caption).weight(.bold))
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
                let ranks = Array(history.playersPoints.sorted(by: {$0.totalPoint > $1.totalPoint}).enumerated())
                
                ForEach (ranks, id: \.element.id) { index, item in
                    Button (action: {
                        withAnimation(.snappy) {
                            if let playerPoint = history.playersPoints.first(where:{$0.pid == item.pid})
                            {
                                viewModel.selectedPlayerTickets = playerPoint.allTickets
                            }
                        }
                    }){
                        VStack (spacing: 0) {
                            Image(uiImage: getImage(uid: item.pid))
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
                                Text(String(item.totalPoint))
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
                .padding([.top,.bottom],25)
                Spacer()
            }
            .background(.indigo)
            .frame(width: getScreenSize().width - 50, alignment: .center)
            .frame(maxHeight:140)
            .clipShape(RoundedRectangle(cornerRadius: 18))
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
        history: Room(
            id: "1",
            ownerID: "1",
            roomCode: "1",
            capacity: 3,
            inUsed: false,
            winner: "",
            createdDateTime: 1705779046.79571,
            playersIDs: ["1","2"],
            playersPoints: [
                PlayerPoint(playerId: "1")
            ]
        )
    )
}
