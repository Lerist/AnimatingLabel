//
// AnimatingLabel.swift
// AnimatingLabel
//
// Created by Paweł Sękara on 23.11.2016.
//
// Copyright 2016 Codewise sp. z o.o. Sp. K.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import UIKit

public protocol TextContainable: class {
    var text: String? { get set }
}

public protocol DigitAnimatable: TextContainable {
    
    func animate(to value: Double, duration: Double, formatter: NumberFormatter?, easingOption: EasingOption)
}

public extension DigitAnimatable {
    
    public func animate(to value: Double, duration: Double = 1, formatter: NumberFormatter? = nil, easingOption: EasingOption = .easeInOut) {
        
        let numberFormatter: NumberFormatter
        if let formatter = formatter {
            numberFormatter = formatter
        } else {
            numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
        }
        
        let text: String = self.text ?? (numberFormatter.string(for: 0) ?? "0")
        
        let number = numberFormatter.number(from: text)?.doubleValue ?? 0
        let diff = value - number
        
        CustomAnimator(duration: duration, easingOption: easingOption, update: { [weak self] progress in
            self?.text = numberFormatter.string(for: number + diff * progress)
            }, completion: { [weak self] _ in
                self?.text = numberFormatter.string(for: value)
        })
    }
}

extension UILabel: DigitAnimatable {}

//MARK: - Implementation


open class CustomAnimator: NSObject {
    private var timer: CADisplayLink?
    
    open private(set) var lastUpdate: TimeInterval
    open private(set) var progress: TimeInterval = 0
    open private(set) var duration: TimeInterval
    
    open var update: ((Double) -> Void)
    open var completion: ((Void) -> Void)?
    
    open private(set) var easingOption: EasingOption
    
    
    @discardableResult
    public init(duration: TimeInterval, easingOption: EasingOption = .easeInOut, update: @escaping (Double) -> Void, completion: ((Void) -> Void)? = nil) {
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        self.duration = duration
        self.update = update
        self.easingOption = easingOption
        self.completion = completion
        
        super.init()
        
        self.timer = CADisplayLink(target: self, selector: #selector(CustomAnimator.tick(timer:)))
        if #available(iOS 10.0, *) {
            self.timer?.preferredFramesPerSecond = 60
        } else {
            self.timer?.frameInterval = 1
        }
        self.timer?.add(to: .main, forMode: .defaultRunLoopMode)
        self.timer?.add(to: .main, forMode: .UITrackingRunLoopMode)
        
        self.update(0)
    }
    
    @objc(tick:) open func tick(timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        self.progress += now - self.lastUpdate
        self.lastUpdate = now
        
        if self.progress > self.duration {
            self.timer?.invalidate()
            self.update(1)
            self.timer = nil
            self.completion?()
            return
        }
        
        self.update(self.easingOption.ease(self.progress / self.duration))
    }
}

public enum EasingOption {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

public extension EasingOption {
    public func ease(_ t: Double) -> Double {
        switch self {
        case .linear:
            return t
        case .easeIn:
            return pow(t, 2)
        case .easeOut:
            return 1.0 - pow(1.0 - t, 2)
        case .easeInOut:
            let sign: Double = -1
            let t = t * 2
            if t < 1 {
                return 0.5 * pow(t, 2)
            } else {
                return sign * 0.5 * (pow(t - 2, 2) + sign * 2)
            }
        }
    }
    
}


