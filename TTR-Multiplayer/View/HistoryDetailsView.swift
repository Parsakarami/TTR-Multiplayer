//
//  HistoryDetailsView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryDetailsView: View {
    @State var history : History
    var body: some View {
        VStack{
            Spacer()
            Text("Room \(history.room.roomCode)")
                .font(.system(.headline))
                .foregroundColor(.white)
                .frame(height: 50, alignment: .center)
                .padding([.leading,.trailing],80)
                .background(.indigo)
                .clipShape(.capsule)
                .padding([.top,.bottom], 10)
            //let first = history.playersTickets
            HStack {
                Spacer()
                let ranks = findTheWinner(playerTickets: history.playersTickets).sorted { $0.value > $1.value }
                
                ForEach (Array(ranks.enumerated()), id: \.1.key) { index, keyValue in
                    VStack {
                        Image(uiImage: getImage(uid: keyValue.key))
                            .resizable()
                            .frame(width: 100 - CGFloat((index * 15)),
                                   height: 100 - CGFloat((index * 15)))
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .padding(5)
                            .shadow(radius: 3, x:-1, y: 1)
                            .overlay {
                                VStack{
                                Spacer()
                                Text(String(keyValue.value))
                                    .font(.system(size: 16 - CGFloat(index + 1)))
                                    .foregroundColor(.white)
                                    .frame(width: 30 - CGFloat(index * 3),
                                           height: 30 - CGFloat(index * 3),
                                           alignment: .center)
                                    .background(.pink)
                                    .clipShape(Circle())
                                }
                                .offset(y:5)
                            }
                        
                        
                    }
                    .offset(x: -(CGFloat(index * 30)))
                    .zIndex(Double(-index))
                }
                Spacer()
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
