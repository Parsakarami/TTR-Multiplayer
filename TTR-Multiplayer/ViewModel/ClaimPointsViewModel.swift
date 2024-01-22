//
//  ClaimPointsViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-21.
//

import Foundation

class ClaimPointsViewModel : ObservableObject {
    @Published var playerPoint : PlayerPoint
    @Published var totalPoints : Int = 0
    @Published var oneTrain : Int = 0
    @Published var twoTrain : Int = 0
    @Published var threeTrain : Int = 0
    @Published var fourTrain : Int = 0
    @Published var fiveTrain : Int = 0
    @Published var sixTrain : Int = 0
    @Published var isLongest : Bool = false
    
    @Published var message : String = ""
    @Published var isSuccessful : Bool = false
    init() {
        let emptyPlayerPoint = PlayerPoint(playerId: "")
        self.playerPoint = emptyPlayerPoint
        
        guard let room = RoomService.instance.currentRoom else {
            return
        }
        
        guard let player = PlayerService.instance.player else {
            return
        }
        
        guard let playerPoint = room.playersPoints.filter({$0.pid == player.id}).first else {
            return
        }

        self.playerPoint = playerPoint
        self.oneTrain = playerPoint.claimedTrains[1]!
        self.twoTrain = playerPoint.claimedTrains[2]!
        self.threeTrain = playerPoint.claimedTrains[3]!
        self.fourTrain = playerPoint.claimedTrains[4]!
        self.fiveTrain = playerPoint.claimedTrains[5]!
        self.sixTrain = playerPoint.claimedTrains[6]!
    }
    
    func updateClaim() {
        guard validate() else {
            return
        }
        
        //claimed longest path
        playerPoint.isLongestPath = isLongest
        let longestPathPoint = isLongest ? 10 : 0
        
        //claimed trains
        playerPoint.claimedTrains[1] = oneTrain
        playerPoint.claimedTrains[2] = twoTrain
        playerPoint.claimedTrains[3] = threeTrain
        playerPoint.claimedTrains[4] = fourTrain
        playerPoint.claimedTrains[5] = fiveTrain
        playerPoint.claimedTrains[6] = sixTrain
        let trainPoints = calculateTrainsPoints()
        
        //claimed destinations
        let destinationPoints = 0
        
        self.totalPoints = trainPoints + longestPathPoint + destinationPoints
        playerPoint.totalPoint = self.totalPoints
        
        // update claim in room service
        Task() {
            let updateResult = try await RoomService.instance.updateRoomClaimedPoints(playerPoins: self.playerPoint)
            if updateResult {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.isSuccessful = true
                    self.message = "Successful"
                }
            }
        }
    }
    
    private func validate() -> Bool{
        guard oneTrain >= 0, twoTrain >= 0, threeTrain >= 0, fourTrain >= 0, fiveTrain >= 0, sixTrain >= 0 else {
            message = "Negative values are not valid."
            return false
        }
        
        return true
    }
    
    private func calculateTrainsPoints() -> Int {
        var result = 0
        
        result = oneTrain
        + (twoTrain * 2)
        + (threeTrain * 4)
        + (fourTrain * 7)
        + (fiveTrain * 10)
        + (sixTrain * 15)
        
        return result
    }
}
