//
//  ViewController.swift
//  Calculator
//
//  Created by Bohdan on 06.06.2024.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var currentValue: String = "0"
    var previousValue: Double = 0.0
    var currentOperation: EnumCurrentOperation? = nil
    var lastOperation: EnumCurrentOperation? = nil
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberLabel.text = currentValue
        swipeOptions()
    }
    
    // MARK: - Setup for Swipe
    
    func swipeOptions() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipe.direction = .right
        numberLabel.addGestureRecognizer(swipe)
        numberLabel.isUserInteractionEnabled = true
    }
    
    // MARK: - Gesture Recognizer
    
    @objc func swipe() {
        if let text = numberLabel.text, !text.isEmpty, text != "0" {
            numberLabel.text = String(text.dropLast())
            if numberLabel.text == "" {
                numberLabel.text = "0"
                currentValue = "0"
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func playSound() {
        AudioServicesPlaySystemSound(1306)
    }
    func convertToDouble() {
        if let currentValueAsDouble = Double(currentValue) {
            previousValue = currentValueAsDouble
            currentValue = ""
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func clearButton(_ sender: Any) {
        // Сбрасываем все переменные (currentValue, previousValue, currentOperation) к исходному состоянию.
        numberLabel.text = "0"
        currentValue = "0"
        previousValue = 0.0
        currentOperation = nil
        lastOperation = nil
        playSound()
    }
    
    
    @IBAction func plusMinusButton(_ sender: Any) {
        // Если currentValue содержит "-" убираем его и наоборот
        if currentValue.contains("-") {
            currentValue = currentValue.replacingOccurrences(of: "-", with: "")
        } else {
            currentValue.insert("-", at: currentValue.startIndex)
        }
        numberLabel.text = currentValue
        playSound()
    }
    
    @IBAction func percentButton(_ sender: Any) {
        if currentOperation != nil {
            currentOperation = .percent
        }
        playSound()
    }
    
    @IBAction func divideButton(_ sender: Any) {
        convertToDouble()
        currentOperation = .division
        lastOperation = .division
        playSound()
        
    }
    
    @IBAction func multiplyButton(_ sender: Any) {
        convertToDouble()
        currentOperation = .multiplication
        lastOperation = .multiplication
        playSound()
    }
    
    @IBAction func minusButton(_ sender: Any) {
        convertToDouble()
        currentOperation = .subtraction
        lastOperation = .subtraction
        playSound()
        
    }
    
    @IBAction func plusButton(_ sender: Any) {
        convertToDouble()
        currentOperation = .addition
        lastOperation = .addition
        playSound()
    }
    
    // MARK: - Enums
    
    enum EnumCurrentOperation {
        case percent
        case division
        case multiplication
        case subtraction
        case addition
    }
    
    // MARK: - Helper Method for other
    
    func performOperation(currentValue: String, previousValue: Double, operationType: EnumCurrentOperation, lastOperation: EnumCurrentOperation?) -> Double {
        guard let currentValueAsDouble = Double(currentValue) else { return previousValue }
        var result: Double = 0.0
        
        switch operationType {
        case .percent:
            if let lastOperation = lastOperation {
                switch lastOperation {
                case .addition:
                    result = previousValue + (previousValue * (currentValueAsDouble / 100))
                case .subtraction:
                    result = previousValue - (previousValue * (currentValueAsDouble / 100))
                case .division:
                    result = previousValue / (currentValueAsDouble / 100)
                case .multiplication:
                    result = previousValue * (currentValueAsDouble / 100)
                default:
                    break
                }
            }
        case .division:
            result = previousValue / currentValueAsDouble
        case .multiplication:
            result = previousValue * currentValueAsDouble
        case .subtraction:
            result = previousValue - currentValueAsDouble
        case .addition:
            result = previousValue + currentValueAsDouble
        }
        return result
    }
    
    // MARK: - Calculation Method
    
    func calculateOperation(currentValue: String, previousValue: Double, operationType: EnumCurrentOperation) {
        let result = performOperation(currentValue: currentValue.isEmpty ? "0" : currentValue, previousValue: previousValue, operationType: operationType, lastOperation: lastOperation)
        
        self.currentValue = String(result)
        numberLabel.text = currentValue
    }
    
    // MARK: - Other button actions
    
    @IBAction func equalButton(_ sender: Any) {
        if let operation = currentOperation {
            let result = performOperation(currentValue: currentValue.isEmpty ? "0" : currentValue, previousValue: previousValue, operationType: operation, lastOperation: lastOperation)
            
            // Удаляем ноль и десятичную точку в конце строки, если они есть
            currentValue = String(result).trimmingCharacters(in: ["0"])
            if currentValue.last == "." {
                currentValue.removeLast()
            }
            
            numberLabel.text = currentValue
            previousValue = result
            currentOperation = nil
            playSound()
        }
    }
    
    @IBAction func dotButton(_ sender: Any) {
        // Проверяем, есть ли уже точка в текущем значении. Если точки нет, добавляем её
        if !currentValue.contains(".") {
            currentValue.append(".")
        }
        numberLabel.text = currentValue
        playSound()
    }
    
    @IBAction func pressedButton(_ sender: UIButton) {
        
        guard let pressed = sender.titleLabel?.text else { return }
        if currentValue == "0" {
            currentValue = pressed
            numberLabel.text = currentValue
        } else {
            currentValue.append(pressed)
            numberLabel.text = currentValue
        }
        playSound()
    }
}
