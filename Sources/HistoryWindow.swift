//
//  HistoryWindow.swift
//  calculatrice
//
//  Created by Philippe on 19/09/2025.
//
import SwiftUI
import AppKit

struct HistoryWindow: View {
    @Binding var history: [String]

    var body: some View {
        VStack(spacing: 12) {
            List(history, id: \.self) { line in
                Text(line)
                    .font(.system(.title, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .textSelection(.enabled)

            HStack {
                Spacer()
               // Button("Copier tout") {
               //     let all = history.joined(separator: "\n")
               //     let pb = NSPasteboard.general
               //     pb.clearContents()
               //     pb.setString(all, forType: .string)
              //  }
               // .disabled(history.isEmpty)

                Button("Effacer", role: .destructive) { history.removeAll() }
                   .disabled(history.isEmpty)
            }
        }
        .frame(minWidth: 380, minHeight: 320)
        .padding()
        .toolbar {
            // (optionnel) dupliquer les actions en barre d'outils en haut de fenêtre
            Button("Copier tout") {
                let all = history.joined(separator: "\n")
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.setString(all, forType: .string)
            }
            .keyboardShortcut("c", modifiers: [.command, .shift]) // ⌘⇧C
            .disabled(history.isEmpty)

            //Button("Effacer", role: .destructive) { history.removeAll() }
                //.keyboardShortcut(.delete, modifiers: [.command])  // ⌘⌫
                //.disabled(history.isEmpty)
        }
    }
}
