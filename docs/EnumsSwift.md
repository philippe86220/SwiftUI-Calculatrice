# 📘 Aide-mémoire Swift : Les Enums

---

## 1. Définition de base

Une **enum** (énumération) définit un ensemble de valeurs possibles pour un type.  
C’est un moyen sûr et lisible d’exprimer un choix parmi des options limitées.

```swift
enum Direction {
    case nord, sud, est, ouest
}

let d = Direction.sud
print(d) // sud
```

---

## 2. Utilisation avec `switch`

```swift
enum Direction {
    case nord, sud, est, ouest
}

func deplacer(_ direction: Direction) {
    switch direction {
    case .nord:
        print("Aller vers le nord")
    case .sud:
        print("Aller vers le sud")
    case .est:
        print("Aller vers l’est")
    case .ouest:
        print("Aller vers l’ouest")
    }
}

let d = Direction.est
deplacer(d) // affiche : Aller vers l’est
```

🧠 Le compilateur Swift **oblige à gérer tous les cas** — sinon, une erreur de compilation apparaît.

---

## 3. Valeurs associées

Les enums peuvent stocker des **données différentes** selon le cas.  
C’est ce qu’on appelle les **valeurs associées**.

```swift
enum Paiement {
    case carte(numéro: String, expiration: String, cvv: String)
    case paypal(email: String)
    case espèces
}

func payer(avec méthode: Paiement) {
    switch méthode {
    case .carte(let numéro, let expiration, let cvv):
        print("Paiement par carte: \(numéro), expiration \(expiration), CVV \(cvv)")
    case .paypal(let email):
        print("Paiement via PayPal (\(email))")
    case .espèces:
        print("Paiement en espèces")
    }
}

let paiement1 = Paiement.carte(numéro: "1234 5678 9012 3456", expiration: "12/27", cvv: "123")
let paiement2 = Paiement.paypal(email: "user@example.com")
let paiement3 = Paiement.espèces

payer(avec: paiement1) // Paiement par carte: 1234 5678 9012 3456, expiration 12/27, CVV 123
payer(avec: paiement2) // Paiement via PayPal (user@example.com)
payer(avec: paiement3) // Paiement en espèces
```

---

## 4. Valeurs brutes (`rawValue`)

Chaque cas peut avoir une **valeur fixe** (entier, chaîne, caractère...).  
Cela permet d’initialiser une enum à partir d’une valeur ou d’obtenir sa représentation.

```swift
enum JourSemaine: Int {
    case lundi = 1
    case mardi, mercredi, jeudi, vendredi, samedi, dimanche
}

let jour = JourSemaine.mercredi
print("Numéro du jour : \(jour.rawValue)") // Numéro du jour : 3

if let jourDeux = JourSemaine(rawValue: 5) {
    print("Le jour 5 est \(jourDeux)") // Le jour 5 est vendredi
}
```

---

## 5. Fonctions et propriétés dans les enums

Les enums Swift sont de vrais types : elles peuvent contenir **des méthodes** et **des propriétés calculées**.

```swift
enum JourSemaine: Int, CaseIterable {
    case lundi = 1, mardi, mercredi, jeudi, vendredi, samedi, dimanche
    
    var estJourOuvré: Bool {
        return self != .samedi && self != .dimanche
    }
    
    func nomFrancais() -> String {
        switch self {
        case .lundi: return "Lundi"
        case .mardi: return "Mardi"
        case .mercredi: return "Mercredi"
        case .jeudi: return "Jeudi"
        case .vendredi: return "Vendredi"
        case .samedi: return "Samedi"
        case .dimanche: return "Dimanche"
        }
    }
    
    func jourSuivant() -> JourSemaine {
        let all = Self.allCases
        let i = all.firstIndex(of: self)!
        return all[(i + 1) % all.count]
    }
}

let aujourdhui = JourSemaine.mardi
print("Aujourdhui: \(aujourdhui.nomFrancais())") // Aujourdhui: Mardi
print("Est-ce un jour ouvré ? \(aujourdhui.estJourOuvré ? "Oui" : "Non")") // Est-ce un jour ouvré ? Oui
print("Jour suivant : \(aujourdhui.jourSuivant().nomFrancais())") // Jour suivant : Mercredi
```
L’énumération `JourSemaine` est un type Swift complet avec une valeur brute `Int`,   
 conformant au protocole `CaseIterable` pour pouvoir itérer sur tous les cas.
•    Elle dispose d’une propriété calculée `estJourOuvré` qui    
    indique si le jour est un jour de semaine ou non.
•    Elle a une méthode `nomFrancais()` qui   
    retourne le nom du jour sous forme d’une chaîne.
•    Une méthode `jourSuivant()` renvoie le jour suivant   
    dans la semaine en utilisant la liste complète des cas.
Cet exemple montre que les énumérations Swift ne servent pas uniquement à lister des valeurs, mais peuvent aussi incarner de la logique cohérente propre à leurs cas.

---

## 6. Cas récursifs

Les enums peuvent être **récursives**, ce qui permet de modéliser des structures comme des arbres d’expression.

```swift
indirect enum Expression {
    case nombre(Int)
    case addition(Expression, Expression)
    case multiplication(Expression, Expression)
    
    func calculer() -> Int {
        switch self {
        case .nombre(let valeur):
            return valeur
        case .addition(let gauche, let droite):
            return gauche.calculer() + droite.calculer()
        case .multiplication(let gauche, let droite):
            return gauche.calculer() * droite.calculer()
        }
    }

    func pretty() -> String {
        switch self {
        case .nombre(let v): return "\(v)"
        case .addition(let g, let d): return "(\(g.pretty()) + \(d.pretty()))"
        case .multiplication(let g, let d): return "(\(g.pretty()) × \(d.pretty()))"
        }
    }
}

let expr = Expression.multiplication(
    .addition(.nombre(3), .nombre(5)),
    .nombre(2)
)

print(expr.pretty())   // ((3 + 5) × 2)
print(expr.calculer()) // 16
```
Le mot-clé `indirect` permet à l’énumération de contenir des cas récursifs, c’est-à-dire des cas dont les valeurs associées peuvent être une instance de la même énumération.
•    Ici, `Expression` modélise une expression arithmétique qui peut être un nombre simple, ou une addition ou multiplication de sous-expressions.
•    La méthode `calculer()` évalue récursivement l’expression pour retourner sa valeur entière.
•    Cette technique est très utile pour représenter des arbres syntaxiques, des calculs mathématiques, ou tout modèle récursif dans Swift.
Ainsi, les enums Swift peuvent aussi servir pour modéliser des structures de données complexes et récursives, en toute sécurité et souplesse.

---

## 7. Techniques avancées

### 🔹 Pattern matching avec `where`

```swift
enum Paiement {
    case carte(numéro: String, expiration: String, cvv: String)
    case paypal(email: String)
    case espèces
}

func payer(avec méthode: Paiement) {
    switch méthode {
    case .carte(let numéro, _, _) where numéro.hasPrefix("4"):
        print("Carte VISA détectée, numéro \(numéro)")
    case .carte(let numéro, let expiration, _):
        print("Carte autre réseau : \(numéro), exp \(expiration)")
    case .paypal(let email):
        print("PayPal : \(email)")
    case .espèces:
        print("Espèces")
    }
}
```

### 🔹 `if case` et `guard case`

```swift
let paiement = Paiement.carte(numéro: "4111...", expiration: "12/27", cvv: "123")

if case let .carte(num, _, _) = paiement {
    print("Numéro de carte : \(num)")
}
```

---

## 8. Enums avec valeurs brutes (String) et propriétés utiles

```swift
enum Jour: String, CaseIterable {
    case lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche
    
    var label: String { rawValue.capitalized }
    var estJourOuvré: Bool { self != .samedi && self != .dimanche }
}

let j: Jour = .mercredi
print(j.label)        // Mercredi
print(j.estJourOuvré) // true
```

---

## 📘 En résumé

| Type d’enum | Particularité | Exemple |
|--------------|----------------|----------|
| Simple | Cas fixes, sûrs, contrôlés par `switch` | `Direction` |
| Valeurs associées | Données différentes selon le cas | `Paiement` |
| Valeurs brutes | Identifiants fixes (`Int`, `String`...) | `JourSemaine` |
| Avec méthodes | Ajout de logique ou propriétés calculées | `JourSemaine` avec `jourSuivant()` |
| Récursive | Représente une structure hiérarchique | `Expression` |

> 💡 Les enums Swift sont bien plus puissantes qu’en C ou C++ : ce sont de **vrais types riches** capables de stocker, décrire et exécuter de la logique métier.
---

## 9. Comparatif global : `struct`, `class` et `enum`

Swift propose trois grands types pour modéliser des données et du comportement :  
les **structures**, les **classes**, et les **énumérations**.  
Chacun a un rôle bien précis.

| Caractéristique | `struct` | `class` | `enum` |
|-----------------|-----------|----------|--------|
| Type de donnée | Valeur | Référence | Valeur |
| Héritage | ❌ Non | ✅ Oui | ❌ Non |
| ARC (compteur de références) | ❌ Non | ✅ Oui | ❌ Non |
| Mutabilité | Modifiable si déclarée `var` | Toujours modifiable si référence mutable | Modifiable si déclarée `var` |
| Initialiseurs personnalisés | ✅ Oui | ✅ Oui | ✅ Oui |
| Extensions | ✅ Oui | ✅ Oui | ✅ Oui |
| Conformance aux protocoles | ✅ Oui | ✅ Oui | ✅ Oui |
| Propriétés calculées et méthodes | ✅ Oui | ✅ Oui | ✅ Oui |
| Valeurs associées | ❌ Non | ❌ Non | ✅ Oui (par cas) |
| Cas multiples définis à la compilation | ❌ Non | ❌ Non | ✅ Oui |
| Comparaison d’identité (`===`) | ❌ Non | ✅ Oui | ❌ Non |
| Conformance automatique à `Equatable` | ✅ Si types simples | ✅ Si toutes les propriétés sont `Equatable` | ✅ Si pas de valeurs associées |
| Type principal pour… | Données autonomes, copiées | Objets avec identité et état partagé | États discrets, logiques de flux |

---

### 🧠 À retenir

- **`struct`** : idéal pour des données **simples et indépendantes**.  
  (Ex. : coordonnées, taille, point, configuration…)

- **`class`** : utile pour des entités **partageant un état** ou ayant besoin d’un **cycle de vie** (ARC, `deinit`).  
  (Ex. : contrôleur d’interface, gestionnaire de ressources…)

- **`enum`** : parfait pour représenter **un ensemble fini d’états possibles**,  
  souvent utilisé avec `switch` pour des **logiques de contrôle**.  
  Peut contenir des **valeurs associées** et du **comportement**.

---

> 💡 En résumé :
> - `struct` et `enum` sont des **types valeur**, légers et copiables.  
> - `class` est un **type référence**, partagé et géré par ARC.  
> - Les `enum` sont uniques en Swift : elles combinent la simplicité des valeurs et la puissance des types riches (méthodes, protocoles, extensions).

---

## 🔍 Comparaison avec les autres langages

Les **énumérations Swift** se distinguent fortement de celles des autres langages de programmation.

### 💡 En résumé rapide

| Langage | Type d’énumération | Description |
|----------|--------------------|--------------|
| **C / C++** | Liste de constantes numériques | Simples entiers nommés, sans données ni comportement. |
| **Java / C#** | Énumérations objets | Peuvent avoir des méthodes, mais pas de valeurs associées dynamiques. |
| **Rust** | `enum` | Très proche de Swift : valeurs associées, pattern matching, exhaustivité. |
| **Haskell / F#** | Types algébriques (`data`, “Discriminated Unions”) | Concept à l’origine des enums Swift modernes. |
| **Kotlin / Scala** | `sealed class`, `enum class`, `case class` | Proches en expressivité, mais plus complexes à écrire. |
| **Swift** | `enum` puissante | Combine données, méthodes, protocoles et pattern matching exhaustif. |

---

### 🧠 Pourquoi c’est unique

- Les enums Swift sont des **types de première classe**, au même titre que `struct` et `class`.  
- Elles peuvent contenir :  
  ✅ des **valeurs associées** (pour chaque cas),  
  ✅ des **propriétés calculées**,  
  ✅ des **méthodes**,  
  ✅ des **extensions**,  
  ✅ et même être **récursives**.  

Swift est donc **l’un des rares langages non purement fonctionnels** à avoir intégré cette puissance de manière simple et naturelle.

---

### 🚀 En une phrase

> **Swift a rendu les enums aussi puissantes que des classes, mais aussi sûres et légères que des structures.**

