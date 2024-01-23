//
//  HistoryRecordView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryRecordView: View {
    @State var history : Room
    var body: some View {
        HStack{
            VStack (alignment: .leading){
                Text(history.roomCode)
                    .font(.system(.title3).weight(.bold))
                    .foregroundStyle(.white)
                
                VStack (alignment:.leading) {
                    let datetime = Date(timeIntervalSince1970: history.createdDateTime)
                    Text(datetime.formatted(date: .numeric, time: .shortened))
                        .font(.system(.caption2))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding([.leading], 5)
            .padding([.top,.bottom],8)
            Spacer()
            HStack (spacing: 0) {
                Spacer()
                ForEach(Array(history.playersPoints.enumerated()), id: \.element.id) { index, item in
                        VStack (spacing: 0) {
                            Image(uiImage: getImage(uid: item.pid))
                                    .resizable()
                                    .frame(width: 45,height: 45)
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(.circle)
                                    .padding([.leading,.trailing], -10)
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
        history:  Room(
                            id: "1",
                            ownerID: "eXlunqDKT1MtM4CJJDsRKuGSiqt2",
                            roomCode: "7",
                            capacity: 4,
                            inUsed: false,
                            winner: "",
                            createdDateTime: 1705858540.4567142,
                            playersIDs: [
                                "eXlunqDKT1MtM4CJJDsRKuGSiqt2",
                                "EIUQ8ORoL6b7BJ99vXk2TGDjCXG3",
                                "akGYW62E0vTfZ6jURYNoITeD4L22",
                                "al0mjFChFCNsDRIce2rXz87HOMa2"
                            ],
                            playersPoints: []
        )
    )
}
