//
//  AddressMarkerView.swift
//  Reverse-Geocoding-SA
//
//  Created by Matthew Sanford on 6/20/18.
//  Copyright © 2018 msanford. All rights reserved.
//

import UIKit

class AddressMarkerView: UIView {

    private var labelContainerHeightConstraint: NSLayoutConstraint

    let viewPadding: CGFloat = 5
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // label container
    let labelContainer: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 5
        container.backgroundColor = UIColor.darkGray
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Pickup, something much longer"
        guard let customFont = UIFont(name: "Muli-SemiBold", size: UIFont.labelFontSize) else {
            fatalError("""
                Failed to load the "Muli-SemiBold" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
            """)
        }
        label.font = customFont
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // marker
    let markerImage: UIImageView = {
        let img = UIImageView()
        img.frame = CGRect(origin: .zero, size: CGSize.init(width: 20, height: 28))
        img.image = #imageLiteral(resourceName: "confirm location view")
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    override init(frame: CGRect) {
        labelContainerHeightConstraint = NSLayoutConstraint(item: labelContainer,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: addressLabel,
                                                            attribute: .height,
                                                            multiplier: 1,
                                                            constant: viewPadding * 2)
        super.init(frame: frame)
        // allow users to "touch through" the view and drag map around
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        labelContainer.layer.borderColor = UIColor.init(red: 97/255,
                                                        green: 161/255,
                                                        blue: 168/255,
                                                        alpha: 1).cgColor
        labelContainer.layer.borderWidth = 2
        labelContainer.addSubview(addressLabel)
        labelContainer.addSubview(activityIndicator)
        addSubview(markerImage)
        addSubview(labelContainer)

        setupMarker()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // When the geocoder is either about to start working, or is finished
    // we want to show/hide the activity indicator and animate the
    // address container resizing to fit the visible view
    public func toggleLoadingState(isSearching: Bool) {
        if isSearching {
            addressLabel.text = ""
            constrainLabelContainerToActivtyView()
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            constrainLabelContainerToAddressLabel()
        }
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }

    }
}

// Setup for the view itself. Nothing relevant here unless you want to see how
// the constraints are initially applied
extension AddressMarkerView {
    private func setupMarker() {
        NSLayoutConstraint.activate([
            // We will change this constraint later on
            labelContainerHeightConstraint,
            labelContainer.bottomAnchor.constraint(equalTo: markerImage.topAnchor, constant: -viewPadding),
            labelContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelContainer.widthAnchor.constraint(greaterThanOrEqualTo: activityIndicator.widthAnchor, constant: viewPadding * 2),

            // Constraining the label to its container which has no width or height constraints
            // allows the container to grow and shrink depending on the length of the address
            addressLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: viewPadding),
            addressLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -viewPadding),
            addressLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor, constant: viewPadding),
            addressLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),

            markerImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            markerImage.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: labelContainer.centerXAnchor),
            ])
    }

    private func constrainLabelContainerToActivtyView() {
        NSLayoutConstraint.deactivate([labelContainerHeightConstraint])
        labelContainerHeightConstraint = NSLayoutConstraint(item: labelContainer,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: activityIndicator,
                                                            attribute: .height,
                                                            multiplier: 1,
                                                            constant: viewPadding * 2)
        NSLayoutConstraint.activate([labelContainerHeightConstraint])
    }

    private func constrainLabelContainerToAddressLabel() {
        NSLayoutConstraint.deactivate([labelContainerHeightConstraint])
        labelContainerHeightConstraint = NSLayoutConstraint(item: labelContainer,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: addressLabel,
                                                            attribute: .height,
                                                            multiplier: 1,
                                                            constant: viewPadding * 2)
        NSLayoutConstraint.activate([labelContainerHeightConstraint])
    }
}
