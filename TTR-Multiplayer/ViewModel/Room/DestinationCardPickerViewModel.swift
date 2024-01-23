//
//  DestinationCardViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-11.
//

import Foundation

class DestinationPickerViewModel : ObservableObject {
    @Published var tickets : [DestinationCardItem] = []
    private var cards : [GameDestinationCard]
    @Published var isPicking = false
    @Published var isValidSelection = false
    init(ticketCards: [GameDestinationCard]) {
        self.cards = ticketCards
        var counter : Int = 0
        for ticket in ticketCards {
            let cardItem = DestinationCardItem(id: counter,
                                               uniqueID: ticket.id,
                                               origin: ticket.origin,
                                               destination: ticket.destination,
                                               point: ticket.point,
                                               isSelected: nil)
            
            tickets.append(cardItem)
            counter += 1
        }
    }
    
    func finilizeSelection() async throws -> Bool {
        guard let player = PlayerService.instance.player,
              let room = RoomService.instance.currentRoom
        else {
            return false
        }
        
        // check two tickets selection in the first round
        guard let playerPoints = room.playersPoints.first(where: {$0.pid == player.id}) else {
            return false
        }
        
        let selectionCount = tickets.filter({ $0.isSelected == true }).count
        // first round selection
        if playerPoints.allTickets.isEmpty {
            isValidSelection = selectionCount >= 2
        } else {
            isValidSelection = selectionCount >= 1
        }
        
        guard isValidSelection else {
            isValidSelection = true
            return false
        }
        
        
        //change the given cards and send them back to the service
        //var updatesCard : [GameDestinationCard]
        for item in tickets.filter({$0.isSelected == true}) {
            if let index = cards.firstIndex(where: { $0.id == item.uniqueID }) {
                cards[index].userID = player.id
                cards[index].isSelected = true
            }
        }
        
        //update and dismiss the sheet
        isPicking = true
        let result = try await RoomService.instance.pickTickets(roomID: room.id, tickets: cards)
        isPicking = false
        return result
    }
}
