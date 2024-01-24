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
            let ranks = Array(history.playersPoints.sorted(by: {$0.totalPoint > $1.totalPoint}).enumerated())
            
            Spacer()
            VStack{
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
                .padding([.top], 10)
            
            HStack {
                Spacer()
                ForEach (ranks, id: \.element.id) { index, item in
                    Button (action: {
                        withAnimation(.snappy) {
                            if let playerPoint = history.playersPoints.first(where:{$0.pid == item.pid})
                            {
                                viewModel.selectedPlayerPoint = nil
                                viewModel.selectedPlayerPoint = playerPoint
                            }
                        }
                    }){
                        VStack (spacing: 0) {
                            Image(uiImage: getImage(uid: item.pid))
                                .resizable()
                                .frame(width: 60 - CGFloat(index * 5), height: 60 - CGFloat(index * 5))
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            
                            HStack {
                                //Winner
                                if index == 0 {
                                    Image(systemName: "checkmark.diamond.fill")
                                        .font(.footnote)
                                        .frame(width:20,height:20)
                                        
                                }
                                Text(String(item.totalPoint))
                                    .offset(x:index == 0 ? -5 : 0)
                            }
                            .frame(minWidth:50 - CGFloat(index * 5))
                            .font(.system(size:CGFloat(15 - index)).weight(.bold))
                            .foregroundColor(.indigo)
                            .background(.white)
                            .clipShape(Capsule())
                            .padding([.top], 7 - CGFloat(index))
                            .padding([.leading,.trailing],3)
                        }
                    }
                    .padding([.top,.bottom],2)
                    
                    if index + 1 != ranks.count {
                        Divider()
                            .padding([.top,.bottom])
                            .padding([.leading,.trailing], ranks.count > 3 ? 0 : 10)
                    }
                }
                Spacer()
            }
            }
            .padding([.bottom])
            .background(.indigo)
            .frame(width: getScreenSize().width - 30 , alignment: .center)
            .frame(maxHeight:170)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            
            Spacer()
            if let playerPoint = viewModel.selectedPlayerPoint {
                ScrollView {
                    ClaimPointsReadOnlyView(playerPoint: playerPoint)
                    .padding()
                }
            }
            Spacer()
        }
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
                PlayerPoint(playerId: "1"),
                PlayerPoint(playerId: "3"),
                PlayerPoint(playerId: "2"),
                PlayerPoint(playerId: "2"),
                PlayerPoint(playerId: "2")
            ]
        )
    )
}
