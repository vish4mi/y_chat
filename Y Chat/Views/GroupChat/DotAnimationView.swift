//
//  DotAnimationView.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import SwiftUI

struct DotAnimationView: View {
    @State private var scale1: CGFloat = 0.5
    @State private var scale2: CGFloat = 0.5
    @State private var scale3: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 5, height: 5)
                .scaleEffect(scale1)
            Circle()
                .frame(width: 5, height: 5)
                .scaleEffect(scale2)
            Circle()
                .frame(width: 5, height: 5)
                .scaleEffect(scale3)
        }
        .foregroundColor(.gray)
        .onAppear {
            withAnimation(Animation.easeInOut.repeatForever().delay(0)) {
                scale1 = 1
            }
            withAnimation(Animation.easeInOut.repeatForever().delay(0.2)) {
                scale2 = 1
            }
            withAnimation(Animation.easeInOut.repeatForever().delay(0.4)) {
                scale3 = 1
            }
        }
    }
}
