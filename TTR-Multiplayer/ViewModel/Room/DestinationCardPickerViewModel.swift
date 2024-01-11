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
    @Published var isAtLeastOneSelected = false
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
        isAtLeastOneSelected = tickets.filter({ $0.isSelected == true }).count > 0
        guard isAtLeastOneSelected else {
            return false
        }
        
        guard let player = PlayerService.instance.player,
              let room = RoomService.instance.currentRoom
        else {
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
