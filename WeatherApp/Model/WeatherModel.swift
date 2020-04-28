//
//  Weather.swift
//  WeatherApp
//
//  Created by kamil.zielinski on 28/04/2020.
//  Copyright © 2020 kamil.zielinski. All rights reserved.
//

import Foundation

/// This code contains temporary mockups. More time for development needed to handle this properly.
struct WeatherModel {

    struct Item {
        let date: Date
        let temp: Double
        let feelsTemp: Double
        let weatherDescription: String
        
        init(_ dict: Dictionary<String, Any>) {
            temp = dict["temp"] as? Double ?? -999
            feelsTemp = dict["feels_like"] as? Double ?? -999
            
            if let dt = dict["dt"] as? Int {
                self.date = Date(timeIntervalSince1970: TimeInterval(dt))
            } else {
                self.date = Date.distantPast
            }

            if let weathers = dict["weather"] as? Array<Dictionary<String, Any>>,
                let weather = weathers.first,
                let description = weather["description"] as? String

            {
                weatherDescription = description
            }
            else {
                weatherDescription = ""
            }
        }
    }
    
    let current: Item
    let upcomming: [Item]
    
    init(_ dict: Dictionary<String, Any>) {
        if let current = dict["current"] as? Dictionary<String, Any> {
            self.current = Item(current)
        } else {
            self.current = Item([:])
        }
        
        if let upcomming = dict["hourly"] as? Array<Dictionary<String, Any>> {
            
            var result = [Item]()
            
            let currentDate = Date()
            for i in 0..<upcomming.count {
                let item = Item(upcomming[i])
                if item.date > currentDate {
                    result.append(item)
                }
                
                if(result.count == 3) {
                    break
                }
            }

            self.upcomming = result
        } else {
            self.upcomming = []
        }
    }
    
    static func empty() -> WeatherModel {
        return WeatherModel([:])
    }
}
