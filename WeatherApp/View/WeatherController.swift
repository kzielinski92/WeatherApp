//
//  ViewController.swift
//  WeatherApp
//
//  Created by kamil.zielinski on 28/04/2020.
//  Copyright © 2020 kamil.zielinski. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherController: UITableViewController {

    @IBOutlet var currentTempLabel: UILabel!
    @IBOutlet var realFeelTempLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    let timeFormatter = DateFormatter()
    
    let disposeBag = DisposeBag()
    
    var vm: WeatherViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.refreshControl = UIRefreshControl()
        tableView.tableFooterView = UIView()
        
        vm = WeatherViewModel(refresh: tableView.refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
                                  API: DefaultOpenWeatherAPI())
        

        vm.loading
            .asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        vm.loading
            .map { !$0 }
            .asDriver(onErrorJustReturn: true)
            .drive(view.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
  
        vm.weather.map { $0.upcomming }
             .bind(to: tableView.rx.items(cellIdentifier: "WeatherCell", cellType: WeatherCell.self)) { [weak self] (row, element, cell) in
                cell.tempLabel.text = "\(element.temp)°"
                cell.descriptionLabel.text = element.weatherDescription
                cell.timeLabel.text = self?.timeFormatter.string(from: element.date)
        }
        .disposed(by: disposeBag)

        let currentWeather = vm.weather.map { $0.current}
        .debug("Weather")
            .share(replay: 1)
            .debug("Current weather")
        
        currentWeather.map { "\($0.temp)°C" }
            .asDriver(onErrorJustReturn: "")
            .drive(currentTempLabel.rx.text)
            .disposed(by: disposeBag)
        
        currentWeather.map { "Real feel: \($0.feelsTemp)°C" }
            .asDriver(onErrorJustReturn: "")
            .drive(realFeelTempLabel.rx.text)
            .disposed(by: disposeBag)
        
        currentWeather.map { [weak self] item in  "\(self?.timeFormatter.string(from: item.date) ?? "")"}
            .asDriver(onErrorJustReturn: "")
            .drive(currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

