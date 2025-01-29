//
//  VisitorGOApp.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

class ParameterParser {
    var parameters: [String: String]

    init(url: String) {
        self.parameters = [:]
        let parameters = url.split(separator: "?")[1].split(separator: "&")
        for param in parameters {
            self.parameters[String(param.split(separator: "=")[0])] = String(param.split(separator: "=")[1])
        }
    }

    func get(_ key: String) -> String? {
        return self.parameters[key]
    }
}

@main
struct VisitorGOApp: App {
    // init helpers
    @ObservedObject var apiHelper: APIHelper = .shared
    var userData: UserData = .shared
    var teamDataHelper: TeamDataHelper = .shared

    @State var index: Int = 0
    @State var verify: Bool = false
    @State var token: String = ""
    @State var isNeedLogin: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    switch (url.host) {
                    case "verify":
                        let parser = ParameterParser(url: url.absoluteString)
                        let token = parser.get("token")
                        if (token != nil) {
                            apiHelper.verifyToken = token
                            verify = true
                        }
                    default:
                        return
                    }
                }
            
                .fullScreenCover(isPresented: $verify) {
                    RegistProfileView()
                }

                .fullScreenCover(isPresented: $isNeedLogin) {
                    LoginView()
                }

                .onAppear {
                    self.isNeedLogin = !apiHelper.isLoggedIn
                }
                .onChange(of: apiHelper.isLoggedIn) {
                    self.isNeedLogin = !apiHelper.isLoggedIn
                }
        }
    }
}
