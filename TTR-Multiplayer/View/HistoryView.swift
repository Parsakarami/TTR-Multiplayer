//
//  HistoryView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel = HistoryViewModel()
    @State private var showHistoryDetails = false
    var body: some View {
        VStack {
            Text("History")
                .font(.system(size: 22,weight: .bold, design: .default))
            
            ScrollView {
                ForEach (viewModel.history) { item in
                    Button (action: {
                        viewModel.selectedHistory = item
                        self.showHistoryDetails = true
                    }) {
                        HistoryRecordView(history: item)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding([.leading,.trailing],15)
                    }
                }
            }
            .sheet(isPresented: $showHistoryDetails, content: {
                VStack{
                    if let history = viewModel.selectedHistory {
                        HistoryDetailsView(history: history)
                    }
                }
            })
            .padding()
        }
    }
}

#Preview {
    HistoryView()
}
