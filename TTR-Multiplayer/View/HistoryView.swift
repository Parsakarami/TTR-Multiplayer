//
//  HistoryView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel = HistoryViewModel()
    
    var body: some View {
        ForEach (viewModel.history) { item in
            Text(item.id)
        }
    }
}

#Preview {
    HistoryView()
}
