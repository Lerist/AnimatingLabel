//
//  AnimatingLabel.swift
//  AnimatingLabel
//
//  Created by Paweł Sękara on 23.11.2016.
//  Copyright © 2016 Codewise sp. z o.o. sp. K. All rights reserved.
//

import Foundation
import UIKit

protocol TextContainable: class {
    var text: String? { get set }
}

protocol DigitAnimatable: TextContainable {
    
    func animate(to value: Double, duration: Double, formatter: NumberFormatter?, easingOption: EasingOption)
}

extension DigitAnimatable {
    
    func animate(to value: Double, duration: Double = 1, formatter: NumberFormatter? = nil, easingOption: EasingOption = .easeInOut) {
        
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


class CustomAnimator: NSObject {
    var timer: CADisplayLink?
    
    var lastUpdate: TimeInterval
    var progress: TimeInterval = 0
    var duration: TimeInterval
    
    var update: ((Double) -> Void)
    var completion: ((Void) -> Void)?
    
    var easingOption: EasingOption
    
    
    @discardableResult
    init(duration: TimeInterval, easingOption: EasingOption = .easeInOut, update: @escaping (Double) -> Void, completion: ((Void) -> Void)? = nil) {
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
    
    @objc(tick:) func tick(timer: Timer) {
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

enum EasingOption {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

extension EasingOption {
    func ease(_ t: Double) -> Double {
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


