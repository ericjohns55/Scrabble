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

struct AlertOptions {
    var title: String = ""
    var message: String = ""
    var buttonText: String = "Dismiss"
}

@MainActor
class PopupManager: ObservableObject {
    @Published public var showToast: Bool = false
    @Published var toastOptions = ToastOptions()
    
    @Published public var showConfirmationDialog: Bool = false
    @Published var confirmationDialogOptions = ConfirmationDialogOptions()
    
    @Published public var showActionSheet: Bool = false
    @Published var actionSheetOptions = ActionSheetOptions()
    
    @Published public var showAlert: Bool = false
    @Published public var alertOptions = AlertOptions()
        
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
    
    func displayAlert(title: String, message: String, buttonText: String = "Dismiss") {
        alertOptions.title = title
        alertOptions.message = message
        alertOptions.buttonText = buttonText
        
        showAlert = true
    }
}

extension View {
    func withPopupManager(_ popupManager: PopupManager) -> some View {
        self
            .alert(popupManager.alertOptions.title, isPresented: Binding(get: { popupManager.showAlert },
                                        set: { popupManager.showAlert = $0 })) {
                Button(popupManager.alertOptions.buttonText, role: .cancel) { }
            } message: {
                Text(popupManager.alertOptions.message)
            }
            .confirmationDialog(popupManager.confirmationDialogOptions.message,
                                isPresented: Binding(get: { popupManager.showConfirmationDialog },
                                                     set: { popupManager.showConfirmationDialog = $0 }),
                                 titleVisibility: popupManager.confirmationDialogOptions.displayTitle ? .visible : .hidden) {
                 Button("Confirm", role: .destructive) {
                     popupManager.confirmationDialogOptions.confirmAction()
                 }
                 
                 Button("Cancel", role: .cancel) {
                     popupManager.confirmationDialogOptions.cancelAction()
                 }
             }
             .actionSheet(isPresented: Binding(get: { popupManager.showActionSheet },
                                               set: { popupManager.showActionSheet = $0 })) {
                 ActionSheet(title: Text(popupManager.actionSheetOptions.title),
                             message: Text(popupManager.actionSheetOptions.message),
                             buttons: popupManager.actionSheetOptions.buttons)
             }
             .toast(isPresenting: Binding(get: { popupManager.showToast },
                                          set: { popupManager.showToast = $0 }),
                    duration: popupManager.toastOptions.toastDuration,
                    tapToDismiss: true) {
                 AlertToast(displayMode: .alert,
                            type: popupManager.toastOptions.toastType,
                            title: popupManager.toastOptions.toastText,
                            style: .style(backgroundColor: popupManager.toastOptions.toastColor))
             }
    }
}
