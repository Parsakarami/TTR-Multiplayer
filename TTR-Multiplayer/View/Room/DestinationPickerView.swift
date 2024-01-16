//
//  DestinationPickerCardView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-07.
//

import SwiftUI

struct DestinationCardItem : Identifiable {
    var id: Int
    var uniqueID : String
    var origin: String
    var destination: String
    var point : Int
    var isSelected : Bool? = nil
}

struct DestinationPickerView: View {
    @StateObject var viewModel : DestinationPickerViewModel
    @Binding var showTheSheet : Bool
    init (cards: [GameDestinationCard], sheetDismisser: Binding<Bool>){
        _viewModel = StateObject(wrappedValue: DestinationPickerViewModel(ticketCards: cards))
        _showTheSheet = sheetDismisser
    }
    
    var body: some View {
        VStack{
            Spacer()
            Spacer()
            VStack {
                ForEach($viewModel.tickets.reversed()) { (card) in
                                DestinationCompactCard(card:card, isSelected: $viewModel.isAtLeastOneSelected)
                        .padding([.leading,.trailing],25)
                }
                Divider()
                    .padding([.top,.bottom])
            }
            .padding([.top,.leading,.trailing])
            
            Spacer()
            Text("Current destinations")
                .font(.system(.title3))
                
            
            ScrollView {
                CurrentDestinationsView(playerCurrentTickets: RoomService.instance.playerCurrentTickets, compact: true)
            }
            .frame(width: getScreenSize().width - 50)
            
            HStack {
                Spacer()
                if !viewModel.isPicking {
                    if viewModel.isAtLeastOneSelected {
                        RoundedTTRButton(action: {
                            Task(priority: .high) {
                                let isSuccessful = try await viewModel.finilizeSelection()
                                if isSuccessful {
                                    showTheSheet = false
                                }
                            }
                        }, title: "Select", icon: "checkmark", bgColor: .blue, fgColor: .blue)
                    } else {
                        
                        if viewModel.tickets.isEmpty {
                            RoundedTTRButton(action: { showTheSheet = false },
                                             title: "back",
                                             icon: "arrow.backward",
                                             bgColor: .blue,
                                             fgColor: .blue)
                        } else {
                            RoundedTTRButton(action: {},
                                             title: "",
                                             icon: "lock.fill",
                                             bgColor: .gray,
                                             fgColor: .gray)
                            .disabled(true)
                        }
                    }
                } else {
                    ProgressView()
                        .padding()
                }
                Spacer()
            }
            .frame(width: getScreenSize().width, alignment: .bottom)
        }.ignoresSafeArea()
    }
}

#Preview {
    DestinationPickerView(cards: [], sheetDismisser: .constant(false))
}
