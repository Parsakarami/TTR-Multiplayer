//
//  ClaimPointsView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-21.
//

import SwiftUI

struct ClaimPointsView: View {
    @StateObject var viewModel = ClaimPointsViewModel()
    var body: some View {
        VStack {
            VStack {
                if !viewModel.isSuccessful {
                    Button(action: {viewModel.updateClaim()})
                    {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Claim")
                        }
                        .foregroundStyle(.background)
                        .frame(alignment: .center)
                        .padding([.leading,.trailing],80)
                        .padding([.top,.bottom], 10)
                        .background(.green)
                        .clipShape(.capsule)
                    }
                    
                    Text("Total points: \(viewModel.playerPoint.totalPoint)")
                        .font(.body)
                    
                } else {
                    Text("Total Points: \(viewModel.playerPoint.totalPoint)")
                        .foregroundColor(.white)
                        .frame(alignment: .center)
                        .padding([.leading,.trailing],80)
                        .padding([.top,.bottom], 10)
                        .background(.indigo)
                        .clipShape(.capsule)
                }
                
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundStyle(viewModel.isSuccessful ? .green : .red)
                }
            }
            .padding(.top,25)
            
            ScrollView {
                VStack (alignment:.center) {
                    Spacer()
                    
                    Text("Longest")
                        .font(.headline)
                        .frame(width:getScreenSize().width - 50 ,alignment: .leading)
                    
                    VStack{
                        Toggle(isOn: $viewModel.playerPoint.isLongestPath) {
                            Text("Do you claim express ticket?")
                        }
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    
                    Text("Trains")
                        .font(.headline)
                        .frame(width:getScreenSize().width - 50 ,alignment: .leading)
                        .padding(.top)
                    VStack {
                        generateStepper(property: $viewModel.oneTrain, number: 1)
                        generateStepper(property: $viewModel.twoTrain, number: 2)
                        generateStepper(property: $viewModel.threeTrain, number: 3)
                        generateStepper(property: $viewModel.fourTrain, number: 4)
                        generateStepper(property: $viewModel.fiveTrain, number: 5)
                        generateStepper(property: $viewModel.sixTrain, number: 6)
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    
                    if viewModel.playerPoint.allTickets.count > 0 {
                        Text("Tickets")
                            .font(.headline)
                            .frame(width:getScreenSize().width - 50 ,alignment: .leading)
                            .padding(.top)
                        
                        VStack{
                            ForEach(viewModel.playerPoint.allTickets) { ticket in
                                let claimed = viewModel.getClaimedTicketValue(forKey: ticket.id)
                                HStack{
                                    Text("\(ticket.point)")
                                    Divider()
                                        .padding([.top,.bottom])
                                    Text("\(ticket.origin) to \(ticket.destination)")
                                    Spacer()
                                    Button(action: {
                                        viewModel.setClaimedTicketValue(false, forKey: ticket.id)
                                    }) {
                                        Image(systemName: "xmark")
                                    }
                                    .padding(10)
                                    .background(claimed == nil ? .gray : !claimed! ? .red : .gray)
                                    .clipShape(.circle)
                                    .foregroundStyle(.white)
                                    
                                    Button(action: {
                                        viewModel.setClaimedTicketValue(true, forKey: ticket.id)
                                    }) {
                                        Image(systemName: "checkmark")
                                    }
                                    .padding(9)
                                    .background(claimed == nil ? .gray : claimed! ? .green : .gray)
                                    .clipShape(.circle)
                                    .foregroundStyle(.white)
                                }
                                .frame(maxHeight: 55)
                                if viewModel.playerPoint.allTickets.last!.id != ticket.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    } else {
                        Spacer()
                    }
                }
            }
        }
        .padding([.leading,.trailing], 20)
        .background(.gray.opacity(0.22))
    }
    
    private func generateStepper(property: Binding<Int>, number: Int) -> some View {
        return HStack{
            Stepper(value: property, label:
                        {
                HStack{
                    generateTrainLabel(number: number)
                    Spacer()
                    Text("\(property.wrappedValue)")
                        .padding(.trailing,10)
                }
            }).font(.system(.body))
        }
    }
    
    private func generateTrainLabel(number: Int) -> some View {
        return HStack (spacing: 0) {
            ForEach (0..<number, id: \.self) { index in
                Image(systemName: "train.side.middle.car")
            }
        }
    }
}

#Preview {
    ClaimPointsView()
}
