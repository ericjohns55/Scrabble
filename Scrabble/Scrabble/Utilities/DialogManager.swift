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

@MainActor
class ConfirmationDialogManager: ObservableObject {
    @Published public var showDialog: Bool = false
    @Published var displayTitle: Bool = true
    @Published var confirmAction: () -> Void = { }
    @Published var cancelAction: () -> Void = { }
    @Published var message: String = ""
    
    func displayDialog(message: String, displayTitle: Bool = true, confirmAction: @escaping () -> Void = { }, cancelAction: @escaping () -> Void = { }) {
        self.message = message
        self.displayTitle = displayTitle
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
        
        showDialog = true
    }
}

