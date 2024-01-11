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
    var offset : CGFloat = 0
}

struct DestinationPickerView: View {
    @StateObject var viewModel : DestinationPickerViewModel
    @State var scrolled = 0
    @Binding var showTheSheet : Bool
    init (cards: [GameDestinationCard], sheetDismisser: Binding<Bool>){
        _viewModel = StateObject(wrappedValue: DestinationPickerViewModel(ticketCards: cards))
        _showTheSheet = sheetDismisser
    }
    
    var body: some View {
        VStack{
            Spacer()
            Text("Choose your destinations")
                .font(.system(.title2))
            Spacer()
            ZStack {
                ForEach($viewModel.tickets.reversed()) { (card) in
                    HStack {
                        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)){
                            VStack{
                                DestinationCardView(card:card,isSelected: $viewModel.isAtLeastOneSelected)
                            }
                            .frame(width: calcwidth(),
                                   height: (UIScreen.main.bounds.height / 1.8) -
                                   CGFloat(card.id - scrolled) * 50)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                            .cornerRadius(18)
                            
                        }
                        .offset(x: card.id - scrolled <= 2 ? CGFloat(card.id - scrolled) * 30 : 60)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                    .offset(x: card.wrappedValue.offset)
                    .gesture(DragGesture().onChanged({value in
                        withAnimation{
                            //Disable last card drag
                            if value.translation.width < 0 && card.id != viewModel.tickets.last!.id {
                                viewModel.tickets[card.id].offset = value.translation.width
                            }else{
                                //Restoring cards
                                if card.id > 0 {
                                    viewModel.tickets[card.id - 1].offset = -(calcwidth() + 60) + value.translation.width
                                }
                            }
                        }
                    }).onEnded({ value in
                        withAnimation{
                            if value.translation.width < 0 {
                                if -value.translation.width > 120 && card.id != viewModel.tickets.last!.id {
                                    viewModel.tickets[card.id].offset = -(calcwidth() + 60)
                                    scrolled += 1
                                } else {
                                    viewModel.tickets[card.id].offset = 0
                                }
                            } else {
                                //Restore cards
                                if card.id > 0 {
                                    if value.translation.width > 120 {
                                        viewModel.tickets[card.id-1].offset = 0
                                        scrolled -= 1
                                    } else {
                                        viewModel.tickets[card.id - 1].offset = -(calcwidth() + 60)
                                    }
                                }
                            }
                        }
                    }))
                }
            }
            .frame(height: UIScreen.main.bounds.height / 1.8)
            .padding(.horizontal,25)
            .padding(.top,15)
            .padding(.leading,10)
            
            Spacer()
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
            .frame(width: getScreenSize().width, height: 120, alignment: .bottom)
        }
    }
    
    func calcwidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 50
        let width = screenWidth - (2 * 30)
        return width
    }
}

//#Preview {
//    DestinationPickerView(ticketCards: [])
//}
