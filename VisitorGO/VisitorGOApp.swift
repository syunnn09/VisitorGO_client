//
//  VisitorGOApp.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

@main
struct VisitorGOApp: App {
    @State var index: Int = 0
    @State var verify: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .onOpenURL { url in
                        switch (url.host) {
                        case "verify":
                            verify = true
                        default:
                            return
                        }
                    }

                    .navigationDestination(isPresented: $verify) {
                        SetPasswordView()
                    }
            }
        }
    }
}
