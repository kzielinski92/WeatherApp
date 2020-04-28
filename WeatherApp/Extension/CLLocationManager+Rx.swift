//
//  CLLocationManager+Rx.swift
//  WeatherApp
//
//  Created by kamil.zielinski on 28/04/2020.
//  Copyright © 2020 kamil.zielinski. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

extension Reactive where Base : CLLocationManager
{
    public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        RxCLLocationManagerDelegateProxy.proxy(for: self.base)
    }
    
    var didChangeAuthorization: Observable<CLAuthorizationStatus> {
        
        return self.delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map { values in
                let v = values[1] as! NSNumber
                return CLAuthorizationStatus.init(rawValue: v.int32Value) ?? CLAuthorizationStatus.notDetermined
        }
    }
    
    public var didUpdateLocations: Observable<[CLLocation]> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base).didUpdateLocationsSubject.asObservable()
    }
    
}

extension CLLocationManager : HasDelegate { }

public class RxCLLocationManagerDelegateProxy
: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    init(locationManager: CLLocationManager) {
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    internal lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager?(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext(locations)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0)}
    }
    
    deinit {
        didUpdateLocationsSubject.onCompleted()
    }
}

