//
//  ButtonStyle.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/5.
//

import SwiftUI

struct SelectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0,maxWidth: 100)
            .foregroundColor(Color.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(40)
            .padding()
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SignButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0,maxWidth: .infinity)
            .foregroundColor(Color.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(40)
            .padding()
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}
