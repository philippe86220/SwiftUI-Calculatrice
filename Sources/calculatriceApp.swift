//
//  calculatriceApp.swift
//  calculatrice
//
//  Created by Philippe on 17/09/2025.
//


import SwiftUI

@main
struct CalculatriceApp: App {
    @State private var history: [String] = []

    var body: some Scene {
        WindowGroup {
            CalculatriceModelView(history: $history) // plus besoin de showHistory ici
                .frame(minWidth: 660, minHeight: 820)
                

        }
        //.defaultSize(width: 760, height: 920)
        // Fenêtre secondaire identifiée
                WindowGroup("Historique", id: "history-window") {
                    HistoryWindow(history: $history)
                }
        
        // Commandes de menu
               .commands {
                   HistoryCommands(history: $history)
               }
    }
}
// Ici tu définis la structure du menu
struct HistoryCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @Binding var history: [String]

    var body: some Commands {
        CommandMenu("Historique") {
            Button("Afficher l’historique") {
                openWindow(id: "history-window")
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Button("Effacer l’historique", role: .destructive) {
                history.removeAll()
            }
            .keyboardShortcut(.delete, modifiers: [.command])
            .disabled(history.isEmpty)
        }
    }
}



