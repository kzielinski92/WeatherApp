//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by kamil.zielinski on 28/04/2020.
//  Copyright © 2020 kamil.zielinski. All rights reserved.
//

import Foundation
import UIKit

/// Represents UI for upcoming weather
class WeatherCell : UITableViewCell
{
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var iconLabel: UIImageView!
}
