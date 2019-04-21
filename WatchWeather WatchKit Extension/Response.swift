//
//  Response.swift
//  WatchWeather WatchKit Extension
//
//  Created by Artem Nikolenko on 12/04/2019.
//  Copyright © 2019 Artem Nikolenko. All rights reserved.
//

import Foundation

struct Response: Codable {
    let timezone: String
    let currently: Currently
}
