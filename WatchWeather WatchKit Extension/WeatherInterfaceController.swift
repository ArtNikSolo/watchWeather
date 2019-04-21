//
//  WeatherInterfaceController.swift
//  WatchWeather WatchKit Extension
//
//  Created by Artem Nikolenko on 12/04/2019.
//  Copyright © 2019 Artem Nikolenko. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON


class WeatherInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    @IBOutlet var city: WKInterfaceLabel!
    @IBOutlet var country: WKInterfaceLabel!
    @IBOutlet var temperature: WKInterfaceLabel!
    @IBOutlet var weatherIcon: WKInterfaceImage!
    @IBOutlet var humidity: WKInterfaceLabel!
    @IBOutlet var windSpeed: WKInterfaceLabel!
    @IBOutlet var weatherPredictionsTable: WKInterfaceTable!
    
    
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if CLLocationManager.locationServicesEnabled() {
            // Location services are available
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        } else {
            // Update your app’s UI to show that the location is unavailable.
            print("location unavaiable")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else {
            print("locations list is empty")
            return
        }
        
        DispatchQueue.main.async {
            self.currentLocation = locations.first!

            let requestString = "https://api.darksky.net/forecast/f58d95e7da7322ce0db755e871955611/\(self.currentLocation!.coordinate.latitude.description),\(self.currentLocation!.coordinate.longitude.description)"
            
            
            Alamofire.request(requestString).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let result):
                    let json = JSON(result)
                     
                    if let locationString = json["timezone"].string?.replacingOccurrences(of: "_", with: " ") {
                        let locationArray = locationString.components(separatedBy: "/")
                        
                        self.country.setText(locationArray[0])
                        self.city.setText(locationArray[1])
                    }
                     
                    let currentWeather = json["currently"]
                     
                    if let temperature = currentWeather["temperature"].float {
                        self.temperature.setText("\(Int(temperature))")
                    } else {
                        self.temperature.setText("--")
                    }
                    
                    if let weatherIcon = currentWeather["icon"].string {
                        self.weatherIcon.setImageNamed(weatherIcon)
                    }
                    
                    if let humidity = currentWeather["humidity"].float {
                        self.humidity.setText("\(Int(humidity*100))%")
                    }
                    
                    if let windSpeed = currentWeather["windSpeed"].float {
                        self.windSpeed.setText("\(windSpeed) mph")
                    }
                    
                    let dailyWeather = json["daily"]["data"]
                    
                    self.weatherPredictionsTable.setNumberOfRows(dailyWeather.count, withRowType: "weatherPrediction")
                    
                    for (index, day) in dailyWeather.enumerated() {
                        guard let controller = self.weatherPredictionsTable.rowController(at: index) as? weatherRowController else {
                            fatalError("Unable cast table row as weatherRowController")
                        }
                        
                        let formatter = DateFormatter.init()
                        formatter.dateFormat = "EEE"
                        let dateNumber = day.1["time"].int
                        let date = Date.init(timeIntervalSince1970: Double(dateNumber!)) //or any date
                        let dayName = formatter.string(from: date)
                        
                        controller.day.setText(dayName)
                        controller.weatherIcon.setImageNamed(day.1["icon"].string)
                        controller.temperature.setText("\(Int(day.1["temperatureHigh"].float!))")
                    }
                    
                case .failure(let error):
                    print("failed to parse response")
                    print(error.localizedDescription)
                    self.temperature.setText("--")
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
