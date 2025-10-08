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

Swift permet de raccourcir la syntaxe des closures de manière progressive.  
Prenons un tableau simple :

```swift
let donnees = [5, 2, 7, 3, 20]
```

### 📝 Version complète

```swift
let classement = donnees.sorted(by: { (a: Int, b: Int) -> Bool in
    return a < b
})
print(classement) // [2, 3, 5, 7, 20]
```

Ici, la closure précise explicitement :
- les **paramètres** avec leurs types (`a: Int`, `b: Int`),
- le **type de retour** (`-> Bool`),
- et utilise `return` pour la comparaison.

---

### ✂️ Version simplifiée (inférence des types)

```swift
let classement2 = donnees.sorted(by: { a, b in a > b })
print(classement2) // [20, 7, 5, 3, 2]
```

➡️ Swift **déduit les types** de `a` et `b` depuis le contexte.  
Le mot-clé `return` devient optionnel car la closure ne contient qu’une seule expression.

---

### 💡 Version ultra courte (paramètres implicites)

```swift
let classement3 = donnees.sorted(by: { $0 < $1 })
print(classement3) // [2, 3, 5, 7, 20]
```

➡️ Swift fournit automatiquement des **noms implicites** `$0`, `$1`, … pour les paramètres.

---

### ✨ Version finale (utilisation directe de l'opérateur)

```swift
let classement4 = donnees.sorted(by: >)
print(classement4) // [20, 7, 5, 3, 2]
```

➡️ Comme les opérateurs `<` et `>` sont eux-mêmes des fonctions `(Int, Int) -> Bool`, on peut les passer directement en argument.

---

✅ Cette progression est très parlante pour comprendre comment Swift permet d’écrire des closures **de plus en plus concises** sans perdre en lisibilité.

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

## 7. Autres mots-clés liés aux closures

En plus du mot-clé `in` (obligatoire dans la syntaxe de la closure), d'autres mots-clés peuvent apparaître **à l'intérieur** ou **autour** d'une closure.

---

### 🧠 7.1 Mots-clés dans le corps de la closure

Une closure peut contenir du code Swift normal, donc on peut y rencontrer :

| Mot-clé | Rôle |
|---------|------|
| `return` | renvoie une valeur depuis la closure |
| `if`, `guard`, `for`, `while` | contrôles de flux |
| `self` | référence explicite à l'objet courant, souvent nécessaire dans les closures capturant `self` |
| `weak`, `unowned` | utilisés dans la liste de capture pour éviter les références fortes cycliques |

Exemple :

```swift
let closure = { [weak self] (a: Int) -> Int in
    guard let self = self else { return 0 }
    if a > 10 {
        return a * 2
    } else {
        return a
    }
}
```

Ici :
- `in` sépare la signature et le corps,
- `[weak self]` est une liste de capture,
- `guard`, `if`, `return` et `self` sont utilisés dans la logique interne.

Ce qui donne par exemple dans une classe :
```swift
class Calculateur {
    var facteur = 3

    func creerClosure() -> (Int) -> Int {
        let closure = { [weak self] (a: Int) -> Int in
            guard let self = self else { return 0 }

            if a > 10 {
                return a * 2 * self.facteur
            } else {
                return a * self.facteur
            }
        }
        return closure
    }
}

let calc = Calculateur()
let closure = calc.creerClosure()
print(closure(12)) // 72
print(closure(8))  // 24
print(closure(2))  // 6
```
✅ Cet exemple :
montre clairement la portée de self,  
illustre l’effet de la closure sur différentes valeurs,  
et démontre l’utilité de guard let self = self.  

---

### ✨ 7.2 Mots-clés autour des closures

Certains mots-clés apparaissent **dans la déclaration** ou **au moment de passer la closure en paramètre**, pour préciser son comportement :

| Mot-clé | Rôle |
|---------|------|
| `@escaping` | indique que la closure peut être appelée après la fin de la fonction appelante (par ex. opérations asynchrones) |
| `@autoclosure` | transforme une expression en closure automatiquement |
| `@Sendable` | impose des règles pour l’exécution concurrente (Swift Concurrency) |
| `try`, `await` | peuvent précéder l'appel d'une closure asynchrone ou qui peut lancer une erreur |

Exemple :

```swift
func executeLater(_ closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        closure()
    }
}
```

Ici :
- `@escaping` modifie la manière dont la closure est stockée et exécutée,
- la closure est exécutée plus tard grâce à `DispatchQueue`.

---

### 📌 À retenir

- ✅ `in` est le **seul mot-clé structurel obligatoire** dans la syntaxe de la closure.  
- ✨ Les autres (`@escaping`, `weak`, `self`, `try`, etc.) sont des outils complémentaires très puissants.  
- 🧠 Bien comprendre ces mots-clés est essentiel pour maîtriser les closures dans des contextes réels (asynchrones, SwiftUI, multithreading).

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
