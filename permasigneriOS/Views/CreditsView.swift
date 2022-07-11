//
//  CreditsView.swift
//  permasigneriOS
//
//  Created by Lilly on 11/07/2022.
//

import SwiftUI

struct GitHubView: View {
    let name: String
    let username: String
    
    var body: some View {
        Link(destination: URL(string: "https://github.com/\(username)")!, label: {
            HStack{
                Text(name)
                Spacer()
                Image("\(name)PFP")
                    .resizable()
                    .frame(width: 32.0, height: 32.0, alignment: .leading)
                    .clipShape(Circle())
            }
        })
    }
}

struct CreditsView: View {
    var body: some View {
        Form {
            Section(header: Text("Permasigner-iOS Developer")) {
                GitHubView(name: "Powen", username: "powenn")
            }
            
            Section(header: Text("Original Permasigner Developer")) {
                GitHubView(name: "itsnebulalol", username: "itsnebulalol")
            }
            
            Section(header: Text("CoreTrust exploit")) {
                GitHubView(name: "Linus Henze", username: "LinusHenze")
                GitHubView(name: "Zhuowei", username: "zhuowei")
            }
            
            Section(header: Text("Help and code contribution")) {
                GitHubView(name: "Lakr233", username: "Lakr233")
                GitHubView(name: "Paisseon", username: "Paisseon")
            }
            
            
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
