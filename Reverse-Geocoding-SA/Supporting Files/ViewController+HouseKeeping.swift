//
//  ViewController+HouseKeeping.swift
//  Reverse-Geocoding-SA
//
//  Created by Matthew Sanford on 6/20/18.
//  Copyright © 2018 msanford. All rights reserved.
//

import UIKit

// This is unimportant to the lesson so I tried to hide it away as best I could think
extension ViewController {

    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func setupConstraints() {
        setupMap()
        setupMarker()
    }

    fileprivate func setupMap() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            mapView.heightAnchor.constraint(equalTo: safeArea.heightAnchor),
            mapView.widthAnchor.constraint(equalTo: safeArea.widthAnchor)
        ])
    }

    fileprivate func setupMarker() {
        NSLayoutConstraint.activate([
            addressMarker.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            addressMarker.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            addressMarker.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addressMarker.bottomAnchor.constraint(equalTo: mapView.centerYAnchor)
        ])
    }
}
