//
//  ScrabbleViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 6/15/25.
//

import AlertToast
import Foundation
import SwiftUI

struct ToastOptions {
    var toastText: String = ""
    var toastColor: Color = .black
    var toastType: AlertToast.AlertType = .regular
    var toastDuration: Double = 2.0
}

struct ConfirmationDialogOptions {
    var displayTitle: Bool = true
    var confirmAction: () -> Void = { }
    var cancelAction: () -> Void = { }
    var message: String = ""
}

struct ActionSheetOptions {
    var title: String = ""
    var message: String = ""
    var buttons: [ActionSheet.Button] = [.cancel()]
}

@MainActor
class PopupManager: ObservableObject {
    @Published public var showToast: Bool = false
    @Published var toastOptions = ToastOptions()
    
    @Published public var showConfirmationDialog: Bool = false
    @Published var confirmationDialogOptions = ConfirmationDialogOptions()
    
    @Published public var showActionSheet: Bool = false
    @Published var actionSheetOptions = ActionSheetOptions()
        
    func displayToast(text: String, color: Color, alertType: AlertToast.AlertType = .regular, duration: Double = 2.0) {
        toastOptions.toastType = alertType
        toastOptions.toastDuration = duration
        toastOptions.toastText = text
        toastOptions.toastColor = color
        
        showToast = true
    }
    
    func displayConfirmationDialog(message: String, displayTitle: Bool = true, confirmAction: @escaping () -> Void = { }, cancelAction: @escaping () -> Void = { }) {
        confirmationDialogOptions.message = message
        confirmationDialogOptions.displayTitle = displayTitle
        confirmationDialogOptions.confirmAction = confirmAction
        confirmationDialogOptions.cancelAction = cancelAction
        
        showConfirmationDialog = true
    }
    
    func displayActionSheet(title: String, message: String, buttons: [ActionSheet.Button]) {
        actionSheetOptions.title = title
        actionSheetOptions.message = message
        actionSheetOptions.buttons = buttons
        
        showActionSheet = true
    }
}
