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
        VStack (alignment:.center) {
            Spacer()
            Text("Total Points: \(viewModel.playerPoint.totalPoint)")
                .foregroundColor(.white)
                .frame(alignment: .center)
                .padding([.leading,.trailing],80)
                .padding([.top,.bottom], 10)
                .background(.indigo)
                .clipShape(.capsule)
                .padding([.top,.bottom])
            
            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .foregroundStyle(viewModel.isSuccessful ? .green : .red)
            }
            
            Form {
                Section("Trains") {
                    generateStepper(property: $viewModel.oneTrain, number: 1)
                    generateStepper(property: $viewModel.twoTrain, number: 2)
                    generateStepper(property: $viewModel.threeTrain, number: 3)
                    generateStepper(property: $viewModel.fourTrain, number: 4)
                    generateStepper(property: $viewModel.fiveTrain, number: 5)
                    generateStepper(property: $viewModel.sixTrain, number: 6)
                    
                    Toggle(isOn: $viewModel.playerPoint.isLongestPath) {
                        Text("Longest path")
                            .foregroundStyle(.indigo)
                    }
                    .padding(3)
                }
            }
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
                                .padding(10)
                                .background(claimed == nil ? .gray : claimed! ? .green : .gray)
                                .clipShape(.circle)
                                .foregroundStyle(.white)
                            }
                            .frame(maxHeight: 55)
                            .padding(5)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(5)
                            
                            if viewModel.playerPoint.allTickets.last!.id != ticket.id {
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: getScreenSize().width - 50)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .foregroundStyle(.indigo)
            
            if !viewModel.isSuccessful {
                RoundedTTRButton(action: {
                    viewModel.updateClaim()},
                                 title: "Claim Points",
                                 icon: "checkmark")
            }
        }
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
                .foregroundColor(.indigo)
            })
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
