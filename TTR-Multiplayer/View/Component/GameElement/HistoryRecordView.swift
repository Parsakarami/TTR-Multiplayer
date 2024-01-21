//
//  HistoryRecordView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryRecordView: View {
    @State var history : History
    var body: some View {
        HStack{
            VStack (alignment: .leading){
                Text(history.room.roomCode)
                    .font(.system(.title3).weight(.semibold))
                    .foregroundStyle(.white)
                
                let datetime = Date(timeIntervalSince1970: history.room.createdDateTime)
                    Text(datetime.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption).weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(datetime.formatted(date: .omitted, time: .shortened))
                        .font(.system(.caption).weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
            }
            .padding()
            Spacer()
            HStack (spacing: 0) {
                ForEach(Array(history.playersTickets.keys.enumerated()), id: \.element) { index, key in
                    if let value = history.playersTickets[key] {
                        VStack (spacing: 0) {
                            Image(uiImage: getImage(uid: key))
                                    .resizable()
                                    .frame(width: 60,height: 60)
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(.circle)
                                    .padding(5)
                                    .shadow(radius: 2, x:-1, y: -1)
                        }
                        .offset(x: -CGFloat((index - 1) * 30))
                    }
                }
            }
            .padding([.trailing],15)
        }
        .padding([.leading,.trailing],5)
        .background(LinearGradient(colors: [.indigo,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
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
    HistoryRecordView(
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
