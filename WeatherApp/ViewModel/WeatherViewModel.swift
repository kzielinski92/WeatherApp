//
//  WeatherViewMode.swift
//  WeatherApp
//
//  Created by kamil.zielinski on 27/04/2020.
//  Copyright © 2020 kamil.zielinski. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class WeatherViewModel  {
    
    let loading: Observable<Bool>
    
    let weather: Observable<WeatherModel>
    
    let locationManager = CLLocationManager()
    let disposeBag = DisposeBag()
    
    let location: Observable<CLLocationCoordinate2D>
    
    init(refresh: Observable<Void>,
         API: OpenWeatherAPI) {
        
        location = locationManager.rx.didUpdateLocations
            .throttle(.seconds(60), scheduler: MainScheduler.instance)
            .map { locations in
                return locations[0].coordinate
        }
        .share(replay: 1)
        
        let loading = ActivityIndicator()
        self.loading = loading.asObservable()
        
        self.weather = Observable.combineLatest(refresh.startWith(()), location)
            .flatMapLatest { _, location in
                return API.weather(for: location)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(WeatherModel.empty())
                    .trackActivity(loading)
        }
        .share(replay: 1)
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}
