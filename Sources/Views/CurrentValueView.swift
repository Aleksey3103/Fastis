//
//  FastisCurrentValueView.swift
//  Fastis
//
//  Created by Ilya Kharlamov on 10.04.2020.
//  Copyright © 2020 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import UIKit
import JTAppleCalendar

final class CurrentValueView<Value: FastisValue>: UIView {
    
    // MARK: - Outlets
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = self.config.placeholderTextColor
        label.text = self.config.placeholderTextForRanges
        label.font = self.config.textFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(CurrentValueView.clear), for: .touchUpInside)
        button.setImage(self.config.clearButtonImage, for: .normal)
        button.tintColor = self.config.clearButtonTintColor
        button.alpha = 0
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: UPDATE UI
    
    private lazy var datePickerFirst: UIDatePicker = {
        let picker = UIDatePicker()
        picker.addTarget(self, action: #selector(datePickerValueChangedFirst(_:)), for: .valueChanged)
        picker.datePickerMode = .date // Adjust this to your desired mode
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    var fromDate = Date()
    var toDate = Date()
    var completion: ((_ value: Value?) -> ())?
    var fastisRange: Value?
    
    
//    @objc private func datePickerValueChangedFirst(_ sender: UIDatePicker) {
//        fromDate = sender.date
//        print("FromDate = \(fromDate)")
//        updateRangeLabel()
//    }
    
    private lazy var datePickerSecond: UIDatePicker = {
        let picker = UIDatePicker()
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    
    @objc private func datePickerValueChangedFirst(_ sender: UIDatePicker) {
        fromDate = sender.date
        updateRangeLabel() // Update the displayed date range and currentValue
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        toDate = sender.date
        updateRangeLabel() // Update the displayed date range and currentValue
    }

    private func updateRangeLabel() {
        if fromDate <= toDate {
            let formattedFromDate = dateFormatter.string(from: fromDate)
            let formattedToDate = dateFormatter.string(from: toDate)
            label.text = "\(formattedFromDate) - \(formattedToDate)"
            
            // Update the currentValue to a FastisRange with the selected fromDate and toDate
            let newValue: FastisRange! = .from(fromDate.startOfDay(in: Calendar.current), to: toDate.endOfDay(in: Calendar.current))
            self.currentValue = newValue as? Value
            fastisRange = self.currentValue
            
            completion?(self.currentValue) // Notify completion handler
        } else {
            label.text = "Invalid Range"
            
        }
    }
    
    func updateDatePickersWithSelectedRange(dateFastis: FastisRange) {
        datePickerFirst.date = dateFastis.fromDate
        datePickerSecond.date = dateFastis.toDate
    }
    
    
//    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
//        toDate = sender.date
//        print("ToDate = \(toDate)")
//        updateRangeLabel()
//    }
//
//
//    private func updateRangeLabel() {
//        if fromDate <= toDate {
//            let formattedFromDate = dateFormatter.string(from: fromDate)
//            let formattedToDate = dateFormatter.string(from: toDate)
//            label.text = "\(formattedFromDate) - \(formattedToDate)"
//            let newValue: FastisRange! = .from(fromDate.startOfDay(in: Calendar.current), to: toDate.endOfDay(in: Calendar.current))
//            self.currentValue = newValue as? Value
//            fastisRange = self.currentValue
//            completion?(self.currentValue)
//        } else {
//            label.text = "Invalid Range"
//        }
//    }
    

    
    
    // MARK: - Variables
    
    private let config: FastisConfig.CurrentValueView
    
    /// Clear button tap handler
    internal var onClear: (() -> Void)?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = self.config.locale
        formatter.dateFormat = self.config.format
        return formatter
    }()
    
    internal var currentValue: Value? {
        didSet {
            self.updateStateForCurrentValue()
        }
    }
    
    // MARK: - Lifecycle
    
    internal init(config: FastisConfig.CurrentValueView) {
        self.config = config
        super.init(frame: .zero)
        self.configureUI()
        self.configureSubviews()
        self.configureConstraints()
        self.updateStateForCurrentValue()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configureUI() {
        self.backgroundColor = .clear
    }
    
    private func configureSubviews() {
        self.containerView.addSubview(self.label)
        self.containerView.addSubview(self.clearButton)
        self.addSubview(self.containerView)
        self.addSubview(self.datePickerFirst)
        self.addSubview(self.datePickerSecond)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            self.clearButton.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
            self.clearButton.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.clearButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.clearButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: self.config.insets.top + 50),
            self.label.bottomAnchor.constraint(equalTo: self.containerView.topAnchor, constant: -8), // Add a gap between label and container
            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 8), // Add a gap between label and container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.config.insets.left),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.config.insets.right),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.config.insets.bottom)
        ])
        
        NSLayoutConstraint.activate([
            self.datePickerFirst.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.datePickerFirst.leftAnchor.constraint(equalTo: self.containerView.leftAnchor),
            self.datePickerFirst.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.datePickerFirst.widthAnchor.constraint(equalTo: self.datePickerSecond.widthAnchor), // Make both pickers equal width
            self.datePickerFirst.trailingAnchor.constraint(equalTo: self.datePickerSecond.leadingAnchor, constant: -30), // Add a gap between pickers
        ])
        
        NSLayoutConstraint.activate([
            self.datePickerSecond.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.datePickerSecond.rightAnchor.constraint(equalTo: self.containerView.rightAnchor,constant: -30),
            self.datePickerSecond.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
        ])
    }

    private func updateStateForCurrentValue() {
        if let value = self.currentValue as? Date {
            self.label.text = self.dateFormatter.string(from: value)
            self.label.textColor = self.config.textColor
            self.clearButton.alpha = 1
            self.clearButton.isUserInteractionEnabled = true

        } else if let value = self.currentValue as? FastisRange {

            self.label.textColor = self.config.textColor
            self.clearButton.alpha = 1
            self.clearButton.isUserInteractionEnabled = true

            if value.onSameDay {
                self.label.text = self.dateFormatter.string(from: value.fromDate)
            } else {
                self.label.text = self.dateFormatter.string(from: value.fromDate) + " – " + self.dateFormatter.string(from: value.toDate)
            }

        } else {

            self.label.textColor = self.config.placeholderTextColor
            self.clearButton.alpha = 0
            self.clearButton.isUserInteractionEnabled = false

            switch Value.mode {
            case .range:
                self.label.text = self.config.placeholderTextForRanges

            case .single:
                self.label.text = self.config.placeholderTextForSingle

            }

        }
    }
    
    // MARK: - Actions
    
    @objc
    private func clear() {
        self.onClear?()
    }
    
}

public extension FastisConfig {
    
    /**
     Current value view appearance (clear button, date format, etc.)
     
     Configurable in FastisConfig.``FastisConfig/currentValueView-swift.property`` property
     */
    struct CurrentValueView {
        
        /**
         Placeholder text in .range mode
         
         Default value — `"Select date range"`
         */
        public var placeholderTextForRanges = "Виберiть перiод"
        
        /**
         Placeholder text in .single mode
         
         Default value — `"Select date"`
         */
        public var placeholderTextForSingle = "Select date"
        
        /**
         Color of the placeholder for value label
         
         Default value — `.tertiaryLabel`
         */
        public var placeholderTextColor: UIColor = .tertiaryLabel
        
        /**
         Color of the value label
         
         Default value — `.label`
         */
        public var textColor: UIColor = .label
        
        /**
         Font of the value label
         
         Default value — `.systemFont(ofSize: 17, weight: .regular)`
         */
        public var textFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
        
        /**
         Clear button image
         
         Default value — `UIImage(systemName: "xmark.circle")`
         */
        public var clearButtonImage: UIImage? = UIImage(systemName: "xmark.circle")
        
        /**
         Clear button tint color
         
         Default value — `.systemGray3`
         */
        public var clearButtonTintColor: UIColor = .systemGray3
        
        /**
         Insets of value view
         
         Default value — `UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)`
         */
        public var insets = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        
        /**
         Format of current value
         
         Default value — `"d MMMM"`
         */
        public var format = "d MMMM"
        
        /**
         Locale of formatter
         
         Default value — `Locale.autoupdatingCurrent`
         */
        public var locale: Locale = .autoupdatingCurrent
    }
}
