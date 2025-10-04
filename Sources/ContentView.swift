//
//  ContentView.swift
//  calculatrice
//
//  Created by Philippe on 17/09/2025.

//
//  Ce projet a été développé avec l’assistance de ChatGPT (OpenAI),
//  dans un but pédagogique personnel. Le code sert de référence
//  pour l'apprentissage de Swift et SwiftUI.
//


//            ┌─────────────┐
//            │   display   │   ← ce que l'utilisateur voit
//            └──────┬──────┘
//                   │
//                   ▼
//           ┌─────────────┐
//           │ utilisateur │
//           │   appuie    │
//           └──────┬──────┘
//                  │
//          ┌───────┼───────────────────────────────────┐
//          │       │                                   │
//          ▼       ▼                                   ▼
//        chiffre   opérateur (+ − × ÷)                "="
//       (0...9)
                                            
//          │       │                                   │
//          ▼       ▼                                   ▼
//    affiche    → si `isTyping` = true :            si `pendingOp` != nil :
//ou concatène    - sauvegarde `display` en          - calcule avec
//               `accumulator`                    `accumulator (lhs)`
//               → met `pendingOp = op`             et `display (rhs)`
//               → prépare saisie suivante          - affiche résultat
//                                                  - `pendingOp = nil`

//

// Exemple de cycle dans la calculatrice :
// Tu tapes 7 → display = "7", pendingOp = nil.
// Tu tapes + → accumulator = 7, pendingOp = "+".
// Tu tapes 3 → display = "3", pendingOp = "+".
// Tu tapes = → compute(7, "+", 3) → display = "10", pendingOp = nil.

// invariants (règles toujours vraies) :
// INV1 : si pendingOp == nil et !isTyping, alors accumulator doit refléter display (on est “au repos”).
// INV2 : si isTyping == true, alors display représente le rhs en cours de saisie.
// INV3 : après une opération unaire (√, 1/x, +/-) sans pendingOp, accumulator == Double(display).

// flux d’événements minimal :
// 5 “moments” et ce qui doit se passer :
// Saisie chiffre → isTyping = true, pendingOp inchangé.
// Op binaire (+ − × ÷) pendant saisie → valider rhs, MAJ accumulator, isTyping = false.
// = → calcule accumulator (lhs) avec display (rhs), pendingOp = nil, isTyping = false.
// Op unaire sans pendingOp → agir sur display, puis syncAccumulatorIfIdle().
// AC → reset total.

import SwiftUI

struct Key: Identifiable {
    let id: Int
    let text: String
    let color: Color
}

let keys: [Key] = [
    .init(id: 0, text: "AC",  color: .orange),
    .init(id: 1, text: "DEL", color: .orange),
    .init(id: 2, text: "%",   color: .orange),
    .init(id: 3, text: "÷",   color: .orange),
    .init(id: 4, text: "√",   color: .orange), // ligne 1

    .init(id: 5, text: "7", color: .yellow),
    .init(id: 6, text: "8", color: .yellow),
    .init(id: 7, text: "9", color: .yellow),
    .init(id: 8, text: "×", color: .orange),
    .init(id: 9, text: "xʸ",  color: .orange), // ligne 2
    
    .init(id: 10, text: "4", color: .yellow),
    .init(id: 11, text: "5", color: .yellow),
    .init(id: 12, text: "6", color: .yellow),
    .init(id: 13, text: "−", color: .orange),
    .init(id: 14, text: "1/x", color: .orange), // ligne 3
    
    .init(id: 15, text: "1", color: .yellow),
    .init(id: 16, text: "2", color: .yellow),
    .init(id: 17, text: "3", color: .yellow),
    .init(id: 18, text: "+", color: .orange),
    .init(id: 19, text: "BIN", color: .orange), // ligne 4
    
    .init(id: 20, text: "+/-", color: .orange),
    .init(id: 21, text: "0",   color: .yellow),
    .init(id: 22, text: ".",   color: .yellow),
    .init(id: 23, text: "=",   color: .orange),
    .init(id: 24 , text: "HEX", color: .orange)  // ligne 5

]


struct CalculatriceModelView: View {
    //Historique
    
    //@Binding var showHistory: Bool // afficher/masquer le panneau
    @Binding var history: [String] // chaque entrée ex: "7 + 3 = 10"
    
    // ——— Variables d’état de la calculatrice ———
        //
        // display    : String affiché à l’écran (nombre en cours ou résultat).
        // accumulator: valeur numérique mémorisée (opérande gauche).
        // pendingOp  : opération en attente ("+", "−", "×", "÷"), nil sinon.
        // isTyping   : vrai si l’utilisateur est en train de saisir un nombre
        //              (permet de savoir s’il faut concaténer ou remplacer).
        // lastKey    : dernière touche appuyée (pratique pour debug/logs).
    
    // ——— Affichage & état de calcul ———
    @State private var display: String = "0"      // ce qui s'affiche avec une chaine de caractères
    @State private var accumulator: Double? = nil // opérande mémorisée (gauche)
    @State private var pendingOp: String? = nil   // opération en attente: "+", "−", "×", "÷" avec une chaine de caractères
    @State private var isTyping: Bool = false     // saisie en cours (pour concaténer les chiffres)
    @State private var lastKey: Key? = nil        // juste pour info / debug si besoin
    @State private var pourCent: Bool = false     // pour effectuer une opération avec un % -->
    // ——— mémorisation de la base ———
    enum NumBase { case dec, bin, hex }
    @State private var lastBase: NumBase = .dec
    // couleur ID: 0 verte ou orange - opérande gauche non nil
    @State private var operationEffectuee: Bool = false


    // ——— Grille : 5 colonnes adaptatives, cases carrées ———
    // 5 colonnes adaptatives, cases carrées
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 5)


    var body: some View {
        VStack(spacing: 8) {
            // Écran d'affichage
            HStack {
                Spacer() // pousse le texte à droite ici display
                Text(display)
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 12)
                Text(lastBase == .dec ? "DEC" : (lastBase == .bin ? "BIN" : "HEX"))
                        .font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.gray.opacity(0.15)).cornerRadius(6)
                        .padding(.trailing, 6)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)
            .padding(.horizontal, 6)
            .contextMenu {
                Button("BIN") { toBinary() }
                Button("DEC") { toDecimal() }
                Button("HEX") { toHex() }
            }
            // Grille des boutons
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(keys) { key in
                    let buttonColor: Color = {
                        if key.id==0 {
                            return  operationEffectuee ? .green : .orange
                        }
                        return key.color
                    }()
                    Button {
                        lastKey = key
                        if let k = lastKey  {print ("key en cours: \(k.text)")} //juste pour voir la dernière touche et test pour déballer un optionnel avec if
                        handleTap(key: key)
                    } label: {
                        ZStack {
                            Rectangle().fill(buttonColor)
                            //Rectangle().fill(key.id==0 ? (operationEffectuee ? Color.white : Color.orange): key.color)
                            Text(key.text)
                                .font(.system(size: 42, weight: .medium, design: .rounded)) //(font.headline)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        //.frame(maxWidth: .infinity, alignment: .leading)
                        .aspectRatio(1, contentMode: .fit) // carré
                        .overlay(Rectangle().stroke(.white, lineWidth: 1))
                        .contentShape(Rectangle())
                    }
                    .disabled(lastBase != .dec && key.text != "AC")
                    .buttonStyle(.plain)
                    .ifLet(keyEquivalent(for: key)) { view, ke in
                        view.keyboardShortcut(ke, modifiers: [])   // ← aucun modificateur
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Logique de calcul
    // ——— Gestion des touches ———

        /// Traite une touche appuyée (chiffre, opérateur, spécialité…)
    private func handleTap(key: Key) {
        let t = key.text
       
        if t == "AC" {allClear(); return}
        
        if t == "DEC" {lastBase = .dec; toDecimal();return}
            
        guard lastBase == .dec else {return } // si on est pas en base 10 on sort
        
        switch t {
        case "√":   applySqrt(); operationEffectuee = true
        case "1/x": applyReciprocal(); operationEffectuee = true
        case "xʸ":  setPendingOperation("^")   // utilise le même mécanisme que +, −, ×, ÷
        case "BIN": toBinary(); operationEffectuee = true
        case "HEX": toHex(); operationEffectuee = true
            
            
        case "DEL":
            if !display.isEmpty {
                display.removeLast()
                if display.isEmpty { display = "0" }
            }
            
        case "+/-": toggleSign()
            
        case "%":
            operationEffectuee = true
            if pendingOp == nil {applyPercent()
            } else {
                pourCent = true ; evaluateIfPossible()
            }
            
            
        case "÷", "×", "−", "+": setPendingOperation(t)
            
        case "=" :
            operationEffectuee = true
            evaluateIfPossible()
            
        case ".":
            inputDot()
            
        default:
            if let _ = Int(t) {
                if pendingOp == nil, accumulator != nil {
                    allClear()
                }
                inputDigit(t)
            }
        }
    }
    
    
    /// Ajoute un chiffre au display.
        /// - Si `isTyping == true` → concatène.
        /// - Si `isTyping == false` → remplace l’affichage par ce chiffre.
    private func inputDigit(_ d: String) {
        print ("isTyping inputDigit DEBUT : \(String(describing: isTyping)) ")
        if isTyping {
            // Eviter les zéros en tête inutiles
            if display == "0" {
                display = d
            } else {
                display.append(d)
            }
        } else {
            display = d
            isTyping = true
        }
        print ("isTyping inputDigit FIN : \(String(describing: isTyping)) ")
    }
    /// Ajoute un point décimal au display.
       /// - Empêche d’avoir deux "." dans le même nombre.
       /// - Si aucune saisie en cours → démarre avec "0."
    private func inputDot() {
        if isTyping {
            if !display.contains(".") {
                display.append(".")
            }
        } else {
            display = "0."
            isTyping = true
        }
    }
    /// Définit une opération en attente.
        /// - Sauvegarde la valeur courante dans `accumulator`.
        /// - Si une opération était déjà en attente → la calcule immédiatement.
        /// - Prépare la saisie du prochain nombre.
    private func setPendingOperation(_ op: String) { //case "÷", "×", "−", "+" et case "xʸ"
        guard lastBase == .dec else { return } // si on est pas en base 10 on sort
        // Si on était en train de taper, on “valide” le nombre courant
        //print ("isTyping setPendingOperation : \(String(describing: isTyping)) ")
        if isTyping {
            if let value = Double(display) {
                if accumulator == nil {
                    accumulator = value
                } else if let p = pendingOp {
                    let result = compute(accumulator ?? 0, p, value)
                    accumulator = result
                    display = result.formattedTrimmed()
                }
            }
            isTyping = false
        } else if accumulator == nil {
            // si pas de saisie en cours mais pas d'accumulateur, prendre l'affichage
            accumulator = Double(display) ?? 0
        }
        pendingOp = op
        dumpState("setPendingOperation")
    }
    /// Évalue l’opération en attente (`pendingOp`) avec `accumulator` et `display`.
        /// - Met à jour le display avec le résultat.
        /// - Vide `pendingOp` pour revenir à l’état neutre.
    private func evaluateIfPossible() { //case "="
        guard let p = pendingOp, lastBase == .dec else { return } //si pas d'opérateur ou on est pas en base 10, on sort
        dumpState("evaluateIfPossible DEBUT")
        let rhs = Double(display) ?? 0
        let lhs = accumulator ?? 0
        let res =  !pourCent ? compute(lhs, p, rhs) : computePourCent(lhs, p, rhs)
        
        if res.isFinite {
            history.insert(historyLineString(lhs: lhs.formattedTrimmed(), op: p, rhs: rhs.formattedTrimmed(), result: res.formattedTrimmed()), at: 0)
            display = res.formattedTrimmed()
            accumulator = res
        } else {
            history.insert(historyLineString(lhs: lhs.formattedTrimmed(), op: p, rhs: rhs.formattedTrimmed(), result: "Erreur"), at: 0)
            display = "Erreur"
            accumulator = nil
        }
        pendingOp = nil
        isTyping = false
        pourCent = false
        dumpState("evaluateIfPossible FIN")
    }


    /// Réinitialise la calculatrice (AC).
        /// - Remet `display = "0"`, vide accumulator et pendingOp.
    private func allClear() {
        display = "0"
        accumulator = nil
        pendingOp = nil
        isTyping = false
        pourCent = false
        lastBase = .dec
        operationEffectuee = false
    }
   
    /// Effectue le calcul entre deux opérandes `a` et `b` selon l’opération donnée.
        /// - Retourne `a op b` (ex: a + b, a × b, etc.).
        /// - Gère la division par zéro → retourne `.infinity`.
    private func compute(_ a: Double, _ op: String, _ b: Double) -> Double {
        switch op {
        case "+": return a + b
        case "−": return a - b
        case "×": return a * b
        case "÷": return b == 0 ? .infinity : a / b  // renvoie .infinity si division par 0
        case "^": return pow(a, b)
        default:  return b
        }
    }
    
    private func computePourCent(_ a: Double, _ op: String, _ b: Double) -> Double {
        switch op {
        case "+": return a + ((b * a) / 100)
        case "−": return a - ((b * a) / 100)
        case "×": return a * (b / 100)
        case "÷": return a / (b / 100)
        default:  return b
        }
    }
    
    // MARK: - Fonctions de gestion du changement de signe, des calculs unaires et des conversions BIN, HEX et DEC
    
    /// Change le signe du nombre affiché.
    private func toggleSign() {
        guard let v = Double(display) else { return }
        display = (-v).formattedTrimmed()

        // Si on n'est pas en train de saisir un chiffre et qu'aucune opération n'est en attente,
        // on synchronise l'accumulateur pour que la prochaine opération prenne bien en compte le lhs.
        // Ne touche pas à isTyping : si l'utilisateur était en saisie, on reste en saisie (on a juste togglé le signe du rhs).
        // Si on venait d'afficher un résultat (=), isTyping est false, donc on vient de synchroniser l'accumulateur (comportement désiré).
        
        syncAccumulatorIfIdle()
        dumpState("toggleSign")
    }
    
    /// Convertit le nombre affiché en pourcentage.
        /// - Divise par 100 et met à jour le display.
    private func applyPercent() { //calcul unaire
        guard let v = Double(display) else { return }
            display = (v / 100.0).formattedTrimmed()
            syncAccumulatorIfIdle()
            dumpState("applyPercent")
        isTyping = false
            history.insert(historyLineUnaire(op: "%", rhs: v.formattedTrimmed(), result: display),at:0)
            // % agit sur l'opérande en cours
            // on sort du mode "typing"
        
    }
    
    private func applySqrt() { //calcul unaire
        guard let v = Double(display), v >= 0 else { display = "Erreur"; return }
        let r = sqrt(v)
        let p = "√"
        display =  r.formattedTrimmed()
        syncAccumulatorIfIdle()
        dumpState("applySqrt")
        isTyping = false
        history.insert(historyLineString( op: p, rhs: v.formattedTrimmed(), result: r.formattedTrimmed()), at: 0)
    }
    
    private func applyReciprocal() { //calcul unaire
        guard let v = Double(display), v != 0 else { display = "Erreur"; return }
        let r = 1.0 / v
        let p = "1/"
        display = r.formattedTrimmed()
        syncAccumulatorIfIdle()
        dumpState("applyReciprocal")
        isTyping = false
        history.insert(historyLineString( op: p, rhs: v.formattedTrimmed(), result: r.formattedTrimmed()), at: 0)
    }
    
    //On rejette les valeurs non entières (v.rounded() == v) et les négatifs (n >= 0),
    //en mettant display = "Erreur" et en consignant l’erreur dans l’historique avec l’entrée originale (rhs: input).
    private func toBinary() {
        guard lastBase == .dec else {return } // si on est pas en base 10 on sort
        guard let v = Double(display), v.isFinite, v.rounded() == v else {
            history.insert(historyLineUnaire(op: "BIN", rhs: display, result: "Erreur"), at: 0)
            display = "Erreur"; isTyping = false
            return
        }
        guard v >= 0 else {
            display = "Erreur"; isTyping = false
            history.insert(historyLineUnaire(op: "BIN", rhs: v.formattedTrimmed(), result: "Erreur"), at: 0)
            return
        }
        let n = Int(v)
        let result = String(n, radix: 2)
        display = result
        isTyping = false
        lastBase = .bin
        history.insert(historyLineUnaire(op: "BIN", rhs: v.formattedTrimmed(), result: result), at: 0)
        dumpState("toBinary")
    }


    private func toHex() { //unaire
        guard lastBase == .dec else { return }
        guard let v = Double(display), v.isFinite, v.rounded() == v else {
            history.insert(historyLineUnaire(op: "HEX", rhs: display, result: "Erreur"), at: 0)
            display = "Erreur"; isTyping = false
            return
        }
        guard v >= 0 else {
            display = "Erreur"; isTyping = false
            history.insert(historyLineUnaire(op: "HEX", rhs: v.formattedTrimmed(), result: "Erreur"), at: 0)
            return
        }
        let n = Int(v)
        let result = String(n, radix: 16).uppercased()
        display = result
        isTyping = false
        lastBase = .hex
        history.insert(historyLineUnaire(op: "HEX", rhs: v.formattedTrimmed(), result: result), at: 0)
        dumpState("toHex")
    }

    private func toDecimal() { //unaire
        guard lastBase != .dec else { return }
        
        let input = display.trimmingCharacters(in: .whitespacesAndNewlines)
        let upper = input.uppercased()

        // Support d’un éventuel signe (au cas où l’utilisateur édite à la main)
        let isNeg = upper.hasPrefix("-")
        let core = isNeg ? String(upper.dropFirst()) : upper
        let sign = isNeg ? -1 : 1

        switch lastBase {
        case .bin:
            if core.allSatisfy({ $0 == "0" || $0 == "1" }), let n = Int(core, radix: 2) {
                let val = Double(sign * n)
                display =  val.formattedTrimmed()
                isTyping = false
                lastBase = .dec
                history.insert(historyLineUnaire(op: "DEC", rhs: "BIN \(isNeg ? "-" : "")\(core)", result: display), at: 0)
            } else {
                display = "Erreur"; isTyping = false
                history.insert(historyLineUnaire(op: "DEC", rhs: "BIN \(input)", result: "Erreur"), at: 0)
            }

        case .hex:
            if core.range(of: "^[0-9A-F]+$", options: .regularExpression) != nil, let n = Int(core, radix: 16) {
                let val = Double(sign * n)
                display = val.formattedTrimmed()
                isTyping = false
                lastBase = .dec
                history.insert(historyLineUnaire(op: "DEC", rhs: "HEX \(isNeg ? "-" : "")\(core)", result: display), at: 0)
            } else {
                display = "Erreur"; isTyping = false
                history.insert(historyLineUnaire(op: "DEC", rhs: "HEX \(input)", result: "Erreur"), at: 0)
            }

        case .dec:
            dumpState("toDecimal")
            // Déjà en décimal : on ne fait rien
            break
        }
    }

    
    // MARK: - gestion de l'historique avec l'horodatage
    
    // ---- Helper horodaté pour l’historique ---- juste pour tester l'horodatage car pas vraiment d'interêt
    private func historyLineString(lhs: String = "", op: String, rhs: String, result: String = "Erreur") -> String {
        return pourCent
        ? "[\(timeStamp())] \(lhs) \(op) \(rhs)% = \(result)"
        : "[\(timeStamp())] \(lhs) \(op) \(rhs) = \(result)"
    }

    private func historyLineUnaire(op: String, rhs: String, result: String) -> String {
        "[\(timeStamp())] \(op) \(rhs) = \(result)"
    }

    
    private func timeStamp() -> String {
        // Cache le DateFormatter pour perf
        struct DF {
            static let f: DateFormatter = {
                let d = DateFormatter()
                d.locale = Locale(identifier: "fr_FR")
                d.timeStyle = .medium     // "14:32:08"
                d.dateStyle = .none
                return d
            }()
        }
        return DF.f.string(from: Date())
    }
    
    // MARK: - fonction de synchronisation de l'accumulateur
    // Si on n'est pas en train de saisir un chiffre et qu'aucune opération n'est en attente,
    // on synchronise l'accumulateur pour que la prochaine opération prenne bien en compte lhs.
    private func syncAccumulatorIfIdle() {
        if pendingOp == nil && !isTyping, let v = Double(display) {
            accumulator = v
        }
    }
    
    // MARK: - fonction de deboggage
    private func dumpState(_ where_: String) {
        print("[STATE @ \(where_)] display=\(display) accumulator=\(String(describing: accumulator)) pendingOp=\(String(describing: pendingOp)) typing=\(isTyping) base=\(lastBase)")
    }
    
    // MARK: - touches du clavier
    private func keyEquivalent(for key: Key) -> KeyEquivalent? {
        switch key.text {
        case "0","1","2","3","4","5","6","7","8","9":
            return KeyEquivalent(Character(key.text))
        case ".": return "."
        case "+": return "+"
        case "−": return "-"     // touche “-” du clavier
        case "×": return "*"     // on mappe × sur la touche *
        case "÷": return "/"     // on mappe ÷ sur la touche /
        case "=": return .return // Entrée/Return
        case "DEL": return .delete
        case "AC": return .escape
        case "√":   return "r"     // ⌘R si tu veux, ou juste r sans modif
        case "xʸ":  return "^"
        case "1/x": return "i"
        case "BIN": return "b"
        case "HEX": return "h"
            
        default: return nil
        }
    }
}

// MARK: - helper pour les touches du clavier
//En Swift, une extension permet d’ajouter des méthodes à un type existant sans le modifier directement.
//Ici, on étend le protocole View (toutes les vues SwiftUI : Text, Button, VStack, etc.).
//➡️ Ça veut dire que toutes les vues auront une nouvelle méthode ifLet.
//👉 ifLet est juste un petit raccourci pratique pour appliquer un modificateur seulement quand une optionnelle n’est pas nil.
//🔑 En résumé :
// extension View { ... } ajoute une méthode à toutes les vues SwiftUI.
// .ifLet(value) { ... } → applique un transform seulement si value existe, sinon la vue reste inchangée.
// Ça rend le code plus compact, mais on peut toujours faire la même chose avec un if let normal.
// utilisé dans la vue ici pour les touches du clavier :
//.ifLet(keyEquivalent(for: key)) { view, ke in
// view.keyboardShortcut(ke, modifiers: [])   // ← aucun modificateur

extension View {
    @ViewBuilder
    func ifLet<T, V: View>(
        _ value: T?,
        transform: (Self, T) -> V
    ) -> some View {
        if let value = value {
            // si l'optionnelle a une valeur :
            // on applique la transformation à la vue
            transform(self, value)
        } else {
            // sinon on rend la vue telle quelle
            self
        }
    }
}

// MARK: - formatage des nombres
//📌 Toujours un cache → NumberFormatter est créé une seule fois par valeur de maximumFractionDigits.
//🧠 Pas de classe séparée → tout est contenu dans l’extension, c’est plus simple à lire.
//🧭 Pas besoin d’un singleton → le struct Cache statique fait le job discrètement.
//🪶 Moins de code → même efficacité, plus concis.
extension Double {
    func formattedTrimmed(maximumFractionDigits: Int = 8) -> String {
        // ✅ Cache statique local à l'extension
        struct Cache {
            static var formatters: [Int: NumberFormatter] = [:]
        }

        if let f = Cache.formatters[maximumFractionDigits] {
            return f.string(from: NSNumber(value: self)) ?? ""
        }

        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US") // décimal = .
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = maximumFractionDigits
        f.numberStyle = .decimal
        f.usesGroupingSeparator = false

        Cache.formatters[maximumFractionDigits] = f
        return f.string(from: NSNumber(value: self)) ?? ""
    }
}
