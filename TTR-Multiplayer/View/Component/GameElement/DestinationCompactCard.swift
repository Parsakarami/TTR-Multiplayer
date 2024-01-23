//
//  DestinationCompactCard.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-16.
//

import SwiftUI

struct DestinationCompactCard: View {
    @Binding var card : DestinationCardItem
    @State var isReadOnly : Bool = false
    @Binding var isSelected : Bool
    
    var body: some View {
            HStack(alignment: .center, spacing: 0){
                Spacer()
                Text(card.origin)
                    .frame(width:120,alignment: .center)
                    .font(.system(.body).weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                VStack{
                    Text(String(card.point))
                        .frame(width: 30, height: 30)
                        .font(.system(.title3).weight(.bold))
                        .foregroundColor(card.isSelected != nil && card.isSelected! ? .green : .indigo)
                        .multilineTextAlignment(.center)
                        .padding(6)
                }
                .background(.white)
                .clipShape(.circle)
                .padding(5)
                
                Text(card.destination)
                    .frame(width:120,alignment: .center)
                    .font(.system(.body).weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(0)
            .background(card.isSelected != nil && card.isSelected! ? .green : .indigo)
            .clipShape(.capsule)
            .onTapGesture {
                withAnimation(.snappy) {
                    guard card.isSelected != nil else {
                        card.isSelected = true
                        isSelected = true
                        return
                    }
                    
                    
                    self.card.isSelected?.toggle()
                    if isSelected == false {
                        isSelected = true
                    }
                }
            }
    }
}

#Preview {
    DestinationCompactCard(card: .constant(DestinationCardItem(id: 0,uniqueID: "2312323132132", origin: "New York", destination: "Seattle", point: 22)), isSelected: .constant(false))
}
