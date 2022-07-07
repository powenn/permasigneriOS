//
//  ExternalView.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/5.
//

import SwiftUI

struct ExternalView: View {
    @State private var inputLink = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("iPA File Link", text: $inputLink)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button(action: {
                    hideKeyboard()
                }, label: {
                    Text("Permanent sign")
                })
                .disabled(inputLink == "")
                .opacity(inputLink == "" ? 0.6 : 1.0)
                .buttonStyle(SignButtonStyle())
            }
            .padding(.bottom)
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .padding()
    }
}

struct ExternalView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalView()
    }
}
