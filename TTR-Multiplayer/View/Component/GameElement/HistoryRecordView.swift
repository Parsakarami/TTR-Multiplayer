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
                Spacer()
                ForEach(Array(history.playersTickets.keys.enumerated()), id: \.element) { index, key in
                        VStack (spacing: 0) {
                            Image(uiImage: getImage(uid: key))
                                    .resizable()
                                    .frame(width: 55,height: 55)
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(.circle)
                                    .padding([.leading,.trailing], -13)
                                    .shadow(radius: 3, x:1, y: 0)
                        }
                        .zIndex(-Double(index))
                }
            }
            .padding([.trailing],25)
            .frame(minWidth: 200)
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
                            ownerID: "eXlunqDKT1MtM4CJJDsRKuGSiqt2",
                            roomCode: "7",
                            capacity: 4,
                            inUsed: false,
                            winner: "",
                            createdDateTime: 1705858540.4567142,
                            playersIDs: ["eXlunqDKT1MtM4CJJDsRKuGSiqt2",
                                         "EIUQ8ORoL6b7BJ99vXk2TGDjCXG3",
                                         "akGYW62E0vTfZ6jURYNoITeD4L22",
                                         "al0mjFChFCNsDRIce2rXz87HOMa2"],
                            playersPoints: []
                         ),
                         playersPoints: ["eXlunqDKT1MtM4CJJDsRKuGSiqt2":30,
                                         "EIUQ8ORoL6b7BJ99vXk2TGDjCXG3":40,
                                         "akGYW62E0vTfZ6jURYNoITeD4L22":50,
                                         "al0mjFChFCNsDRIce2rXz87HOMa2":75],
                         playersTickets: {
                             [:]
                         }())
    )
}
