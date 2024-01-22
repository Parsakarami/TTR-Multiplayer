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
    
    @Published var message : String = ""
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
        // update claim in room service
        Task() {
            let updateResult = try await RoomService.instance.updateRoomClaimedPoints(playerPoins: self.playerPoint)
            if updateResult {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    //Do something
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
}
