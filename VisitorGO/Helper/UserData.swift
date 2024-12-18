//
//  UserData.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/18.
//

import SwiftUI

class UserData: ObservableObject {
    static let shared = UserData()

    @Published var userProfile: Profile?

    init() {
        getProfile()
    }

    func getProfile() {
        APIHelper.shared.getUserData(completion: setProfile)
    }

    func setProfile(success: Bool, profile: Profile?) {
        if success && profile != nil {
            self.userProfile = profile
        }
    }
}
