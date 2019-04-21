
//
//  Currently.swift
//  WatchWeather WatchKit Extension
//
//  Created by Artem Nikolenko on 12/04/2019.
//  Copyright © 2019 Artem Nikolenko. All rights reserved.
//

import Foundation

struct Currently: Codable {
    let temperature: Double
    let icon: String
    let humidity: String
    let summary: String
}
