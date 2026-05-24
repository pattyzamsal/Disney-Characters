//
//  Environment.swift
//  Disney Characters
//
//  Created by Patricia Zambrano on 24/05/26.
//

import Foundation

enum Environment {
    static var baseURL: String {
        guard let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
              !url.isEmpty else {
            fatalError("API_BASE_URL not set in xcconfig")
        }
        return url
    }
}
