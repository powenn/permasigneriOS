//
//  LocalView.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/5.
//

import SwiftUI
import UniformTypeIdentifiers
import AuxiliaryExecute
import ZipArchive

struct LocalView: View {
    
    @State var isImporting: Bool = false
    @State var fileName:String = ""
    @State var filePath:String = ""
    @State var showAlert:Bool = false
    @State var alertTitle:String = ""
    @State var alertMeaasge:String = ""
    @State var isProgressing:Bool = false
    @State var showInFilzaAlert:Bool = false
    @State var canShowinFilza:Bool = false
    
    func signFailedAlert(title:String, message:String) {
        fileName = ""
        alertTitle = title
        alertMeaasge = message
        removeInvalidFile()
        showAlert.toggle()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(fileName != "" ? "\(fileName)" : "No ipa file selected")
                Button(action: {isImporting.toggle()}, label: {Text("Select File")})
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertTitle), message: Text(alertMeaasge), dismissButton: .default(Text("OK")))
                    }
                    .padding()
                Button(action: {
                    isProgressing = true
                    permanentSignButtonFunc(FileName: fileName)
                    if CheckDebBuild(inputFileName: fileName) {
                        if checkFilza() {
                            canShowinFilza = true
                        } else { canShowinFilza = false }
                        showInFilzaAlert.toggle()

                    } else {
                        signFailedAlert(title: "Sign Failed", message: "Please try others iPA files")
                    }
                }, label: {Text("Permanent sign")})
                .alert(isPresented: $showInFilzaAlert ){
                    Alert(
                        title: Text(canShowinFilza ? "Done" : "Ohh no"),
                        message: Text(canShowinFilza ? "View the file now ?" : "You need Filza to view the file"),
                        primaryButton: .default(Text("Okay")) {
                            if canShowinFilza {
                                UIApplication.shared.open(URL(string: "filza://\(OutputDebFilePath)")!)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .disabled(fileName == "")
                .opacity(fileName == "" ? 0.6 : 1.0)
                .buttonStyle(SignButtonStyle())
                .padding()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType(filenameExtension: "ipa")!],
                allowsMultipleSelection: false
            ) { result in
                do {
                    let fileUrl = try result.get()
                    self.fileName = fileUrl.first!.lastPathComponent
                    self.filePath = fileUrl.first!.path
                    
                    extractIpa(FileName: fileName, FilePath: filePath)
                    
                    if checkIsIpaPayloadValid(payloadPath.path) {
                        InfoPlistPath = payloadPath.appendingPathComponent("\(appNameInPayload)/Info.plist")
                        if checkInfoPlist(InfoPlistPath!.path) {
                            getInfoPlistValue(InfoPlistURL: InfoPlistPath!)
                            if validInfoPlist {
                                print("valid InfoPlist")
                            } else {
                                app_executable = nil
                                signFailedAlert(title: "No executable found.", message: "Missing executable in Info.plist")
                            }
                        }
                    } else {
                        signFailedAlert(title: "IPA is not valid!", message: "The file might have missing parts\nor invalid contents")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .padding()
        }
//        .sheet(isPresented: $isProgressing, content: {
//        })
    }
}


struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView()
    }
}
