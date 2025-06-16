//
//  ScrabbleViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 6/15/25.
//

import AlertToast
import Foundation
import SwiftUI


@MainActor
class ToastManager: ObservableObject {
    @Published public var showToast: Bool = false
    @Published var toastText: String = ""
    @Published var toastColor: Color = .black
    @Published var toastType: AlertToast.AlertType = .regular
    @Published var toastDuration: Double = 2.0
        
    func displayToast(text: String, color: Color, alertType: AlertToast.AlertType = .regular, duration: Double = 2.0) {
        toastType = alertType
        toastDuration = duration
        toastText = text
        toastColor = color
        
        showToast = true
    }
}
