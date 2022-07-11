//
//  ButtonStyle.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/5.
//

import SwiftUI

struct SignButtonStyle: ButtonStyle {
    @StateObject var progress: Progress = .shared
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0,maxWidth: .infinity)
            .foregroundColor(Color.white)
            .padding()
            .background(
                GeometryReader { geo in
                    Color.blue
                        .opacity(0.5)
                    Color.blue
                        .frame(width: geo.size.width * progress.Percent)
                        .animation(.easeIn)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .padding()
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}
