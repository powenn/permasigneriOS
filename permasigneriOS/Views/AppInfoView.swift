//
//  AppInfoView.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/5.
//

import SwiftUI

struct AppInfoView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let buildVer = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    @State var cleanFolderDone:Bool = false
    @State var showCantOpenInFilza:Bool = false
    @State var showCredits:Bool = false
    
    var body: some View {
        Form{
            Section(header: Text("version")){
                Text("\(appVersion!).\(buildVer!)")
            }
            Section(header: Text("Source Code")){
                Link(destination: URL(string: "https://github.com/powenn/permasigneriOS")!, label: {
                    HStack{
                        Text("View on Github")
                        Spacer()
                        Image("GithubIcon")
                            .resizable()
                            .frame(width: 32.0, height: 32.0, alignment: .leading)
                    }
                })
                Link(destination: URL(string: "https://github.com/powenn/permasigneriOS/issues?q=")!, label: {
                        Text("Check issues on Github")
                })
            }
            Button(action: {showCredits.toggle()}, label: {
                Text("Credits")
            })
            .sheet(isPresented: $showCredits, content: {CreditsView()})
            Button(action: {
                if !checkFilza() {
                    showCantOpenInFilza.toggle()
                } else {
                    showCantOpenInFilza = false
                    UIApplication.shared.open(URL(string: "filza://\(documentsDirectory)")!)
                }
            }, label: {
                Text("Open Package Folder in Filza")
            })
            .alert(isPresented: $showCantOpenInFilza, content: {
                Alert(title: Text("Oh no"), message: Text("You need Filza to view the file"),dismissButton: .default(Text("Okay")))
            })
            
            Button(action: {
                try? FileManager.default.removeItem(at: OutputPackageDirectory)
                setPathAndTmp()
                cleanFolderDone.toggle()
            }, label: {
                Text("Clear All Packages")
            })
            .alert(isPresented: $cleanFolderDone,content: {
                Alert(title: Text("Done"), message: Text("All packages in Package Folder have been removed"), dismissButton: .default(Text("Okay")))
            })
            Section(footer: Text("Document Folder Path\n/var/mobile/Documents/permasigneriOS\n\nPlease be patient during the sign process,\nespecially signing a complex app with\nlots of frameworks\n\nIf you're having problems, please check Github issues before asking\n\nThis is iOS ported of itsnebulalol's permasigner"), content: {})
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
