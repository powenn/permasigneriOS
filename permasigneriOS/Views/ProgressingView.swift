//
//  ProgressingView.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/7.
//

import SwiftUI

struct ProgressingView: View {
    @State var currentProgressDescribe = ProgressDescribe
    var body: some View {
        ProgressView(label: {
            Text(currentProgressDescribe)
        })
    }
}

struct ProgressingView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressingView()
    }
}
