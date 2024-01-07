//
//  DestinationCard.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-06.
//

import SwiftUI

//Add destination struct

struct DestinationCardView: View {
    @State var isSelected : Bool? = nil
    @State var isReadOnly : Bool = false
    var body: some View {
        ZStack (alignment: .center){
            VStack{
                VStack{
                    HStack{
                        Spacer()
                        Text("New York")
                            .frame(width: 140,alignment: .center)
                            .font(.system(size: 22,weight: .bold,design: .monospaced))
                            .multilineTextAlignment(.center)
                        Spacer()
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 35))
                        Spacer()
                        Text("Seattle")
                            .frame(width: 140,alignment: .bottom)
                            .font(.system(size: 22,weight: .bold,design: .monospaced))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxHeight:100)
                    .foregroundColor(.white)
                    .background(.blue)
                    VStack{
                        Text("22")
                            .frame(width: 140,alignment: .bottom)
                            .font(.system(size: 45,weight: .heavy,design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .rotationEffect(.degrees(45))
                    }
                    .frame(maxWidth: 90,maxHeight:90)
                    .background(.blue)
                    .cornerRadius(25)
                    .rotationEffect(.degrees(-45))
                    .padding()
                    }
                Spacer()
                if !isReadOnly {
                    VStack{
                        if let isSelected = isSelected {
                            Image(systemName: isSelected ? "checkmark" : "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 110,weight: .semibold))
                                .frame(maxWidth: 200,maxHeight:200)
                                .background(isSelected ? .green : .red)
                                .clipShape(.circle)
                        }
                    }
                }
                Spacer()
                if !isReadOnly {
                    HStack{
                        Button(action:{
                            withAnimation(.snappy) {
                                isSelected = false
                            }
                        }){
                            Image(systemName: "xmark")
                                .font(.system(size: 35,weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: 70,maxHeight:70)
                        .background(.red)
                        .clipShape(.circle)
                        .shadow(radius: 8)
                        .padding(.leading,50)
                        Spacer()
                        
                        Button(action:{
                            withAnimation(.snappy) {
                                isSelected = true
                            }
                        }){
                            Image(systemName: "checkmark")
                                .font(.system(size: 35,weight: .bold))
                        }
                        .frame(maxWidth: 70,maxHeight:70)
                        .background(.green)
                        .clipShape(.circle)
                        .shadow(radius: 8)
                        .padding(.trailing,50)
                        
                    }
                    .frame(maxWidth:.infinity, maxHeight:100)
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(Image("User").resizable().aspectRatio(contentMode: .fill))
        .ignoresSafeArea()
    }
}

#Preview {
    DestinationCardView()
}
