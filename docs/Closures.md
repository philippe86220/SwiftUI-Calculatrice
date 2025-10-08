# 📌 Aide-mémoire Swift : Les Closures

---

## 1. Définition

Une **closure** en Swift est un **bloc autonome de code**, sans nom, qui peut être :
- stocké dans une variable ou constante,
- passé en paramètre à une fonction,
- ou exécuté plus tard dans le programme.

Les closures peuvent **capturer et utiliser les variables** de leur contexte environnant, même en dehors de leur portée d’origine.

---

## 2. Syntaxe générale

```swift
{ (paramètres) -> TypeRetour in
    instructions
}
```

- Les paramètres et le type de retour sont **optionnels** si Swift peut les déduire.
- Le mot-clé `in` sépare la **signature** du **corps** de la closure.

---

## 3. Exemple simple

```swift
let donnees = [5, 2, 7, 3, 20]

func traiterNombres(
    _ nombres: [Int],
    enUtilisant operation: (Int, Int) -> Int
) -> Int {
    guard var resultatActuel = nombres.first else { return 0 }
    for i in 1..<nombres.count {
        resultatActuel = operation(resultatActuel, nombres[i])
    }
    return resultatActuel
}

// Addition via closure
let somme = traiterNombres(donnees, enUtilisant: { (a: Int, b: Int) -> Int in
    return a + b
})

// Multiplication via closure
let produit = traiterNombres(donnees, enUtilisant: { (a: Int, b: Int) -> Int in
    return a * b
})

print("Somme : \(somme)")         // 37
print("Produit : \(produit)")     // 4200
```

---

## 4. Simplification de syntaxe

Swift permet de raccourcir la syntaxe des closures :

```swift
// Version complète
donnees.sorted(by: { (a: Int, b: Int) -> Bool in
    return a < b
})

// Version simplifiée
donnees.sorted(by: { a, b in a < b })

// Encore plus courte avec les noms implicites $0, $1
donnees.sorted(by: { $0 < $1 })

// Et enfin, comme < est déjà une fonction, on peut écrire :
donnees.sorted(by: <)
```

---

## 5. Captures de variables

Les closures peuvent capturer et modifier des variables **extérieures** :

```swift
var compteur = 0

let incrementeur = {
    compteur += 1
    print("Compteur = \(compteur)")
}

incrementeur() // Compteur = 1
incrementeur() // Compteur = 2
```

👉 Ici, la closure conserve une **référence à `compteur`** même après la fin de sa portée d’origine.

---

## 6. Utilisation courante

Les closures sont très utilisées dans SwiftUI, les API asynchrones et les animations :

```swift
// Exemple SwiftUI : action de bouton
Button("Cliquez-moi") {
    print("Bouton pressé !")
}
```

```swift
// Exemple asynchrone
URLSession.shared.dataTask(with: url) { data, response, error in
    print("Requête terminée")
}.resume()
```

---

## 📌 Résumé rapide

| Élément | Détail |
|--------|--------|
| ✅ Définition | Bloc de code autonome et sans nom |
| 🧠 Capture | Peut capturer et modifier le contexte environnant |
| 💬 Syntaxe | `{ (params) -> TypeRetour in ... }` |
| ✂️ Raccourcis | `$0`, `$1`, inférence de types, opérateurs |
| ⚡ Usage | Tri, actions différées, callbacks, SwiftUI, async |

---
