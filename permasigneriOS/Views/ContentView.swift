//
//  ContentView.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/5.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView{
            SignView()
                .tabItem({
                    Label("Sign", systemImage: "signature")
                })
            AppInfoView()
                .tabItem({
                    Label("AppInfo", systemImage: "info.circle.fill")
                })
        }
        .onAppear(perform: {
            // Setup basic path and tmp **DirectoryPath.Swift**
            setPathAndTmp()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
