//
//  OpenWeatherAPI.swift
//  WeatherApp
//
//  Created by kamil.zielinski on 28/04/2020.
//  Copyright © 2020 kamil.zielinski. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

protocol OpenWeatherAPI {
    func weather(for coordinates: CLLocationCoordinate2D) -> Observable<WeatherModel>
}

class DefaultOpenWeatherAPI: OpenWeatherAPI {
    
    let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!
    let apiKey = "c739f0670695271af6a41556bd698e35"//it should be environment variable
    
    func weather(for coordinates: CLLocationCoordinate2D) -> Observable<WeatherModel> {
        
        let request = buildRequest(pathComponent: "onecall", params: [
            ("lat", "\(coordinates.latitude)"),
            ("lon",  "\(coordinates.longitude)")
        ])
        
        return request.map { json in
            return WeatherModel(json)
        }
    }
    
    private func buildRequest(pathComponent: String, params: [(String, String)]) -> Observable<Dictionary<String, Any>> {
        let url = self.baseURL.appendingPathComponent(pathComponent)
        
        let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
        let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
        
        var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1)}
        queryItems.append(keyQueryItem)
        queryItems.append(unitsQueryItem)

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        var req: URLRequest = URLRequest(url: url)
        req.httpMethod = "GET"
        req.url = urlComponents.url!
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let request: Observable<URLRequest> = Observable.just(req)
        
        
        let session = URLSession.shared
        return request.flatMap { rqst in
            return session.rx.json(request: rqst)
                .map { $0 as! Dictionary }
        }
    }
}
