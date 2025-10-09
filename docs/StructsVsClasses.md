# 📌 Aide-mémoire Swift : Structs vs Classes

---

## 1. Points communs

- Définissent des **types personnalisés** avec propriétés et méthodes.
- Peuvent avoir des **initialiseurs**, des **extensions**, et **conformer à des protocoles**.
- Peuvent toutes deux utiliser des **protocoles**, des **computed properties**, et des **fonctions membres**.

---

## 2. Différences fondamentales

| Caractéristique | `struct` | `class` |
|-----------------|----------|---------|
| Stockage | **Valeur** (copie) | **Référence** (pointeur vers une instance) |
| Héritage | ❌ Non pris en charge | ✅ Héritage entre classes |
| ARC (gestion mémoire) | ❌ Pas concerné | ✅ Géré par ARC |
| Mutabilité | Propriétés modifiables uniquement si `var` | Toujours modifiables si référence mutable |
| Performance | Très efficace (copie optimisée) | Léger surcoût lié à l’ARC |
| Identité (`===`) | Non applicable | Oui, permet de comparer les instances |
| `deinit` | Non disponible | ✅ Disponible pour libérer les ressources |

---

## 3. Exemple de calculateur (Struct)

```swift
struct Calculator: CustomStringConvertible {
    var numbers: [Double]
    var operation: String
    var result: Double
    init(numbers: [Double], operation: String) {
        self.numbers = numbers
        self.operation = operation
        switch operation {
        case "add":
            self.result = numbers.reduce(0, +)
        case "subtract":
            self.result = numbers.dropFirst().reduce(numbers.first ?? 0, -)
        case "multiply":
            self.result = numbers.reduce(1, *)
        case "divide":
            self.result = numbers.dropFirst().reduce(numbers.first ?? 1, /)
        default:
            self.result = 0
        }
    }
    var description: String {
        return String(format: "Résultat : %.6f", result)
    }
}

let calcAdd = Calculator(numbers: [1.1, 2.2, 3.3], operation: "add")
print(calcAdd) // Résultat : 6.600000
let calcSub = Calculator(numbers: [10.0, 4.0, 1.5], operation: "subtract")
print(calcSub) // Résultat : 4.500000
let calcMul = Calculator(numbers: [2.0, 3.0, 4.0], operation: "multiply")
print(calcMul) // Résultat : 24.000000
let calcDiv = Calculator(numbers: [100.0, 2.0, 5.0], operation: "divide")
print(calcDiv) // Résultat : 10.000000
```

---

## 4. Exemple de calculateur (Class)

```swift
class Calculator: CustomStringConvertible {
    var numbers: [Double]
    var operation: String
    var result: Double
    init(numbers: [Double], operation: String) {
        self.numbers = numbers
        self.operation = operation
        switch operation {
        case "add":
            self.result = numbers.reduce(0, +)
        case "subtract":
            self.result = numbers.dropFirst().reduce(numbers.first ?? 0, -)
        case "multiply":
            self.result = numbers.reduce(1, *)
        case "divide":
            self.result = numbers.dropFirst().reduce(numbers.first ?? 1, /)
        default:
            self.result = 0
        }
    }
    var description: String {
        return String(format: "Résultat : %.6f", result)
    }
}

let calcAdd = Calculator(numbers: [1.1, 2.2, 3.3], operation: "add")
print(calcAdd) // Résultat : 6.600000
let calcSub = Calculator(numbers: [10.0, 4.0, 1.5], operation: "subtract")
print(calcSub) // Résultat : 4.500000
let calcMul = Calculator(numbers: [2.0, 3.0, 4.0], operation: "multiply")
print(calcMul) // Résultat : 24.000000
let calcDiv = Calculator(numbers: [100.0, 2.0, 5.0], operation: "divide")
print(calcDiv) // Résultat : 10.000000
```

---

### ⚖️ Différence entre `struct` et `class` avec le même code

Les deux versions du `Calculator` ci-dessus fonctionnent **exactement de la même manière en apparence** :  
elles reçoivent des nombres, effectuent une opération, et retournent un résultat.

Mais en réalité, leur **comportement mémoire** est très différent.

---

#### 🧱 Version `struct` → Type **valeur**

Chaque fois que vous **copiez ou passez** une structure,  
vous créez une **nouvelle instance indépendante** avec son propre état.

```swift
var s1 = Calculator(numbers: [1, 2, 3], operation: "add")
var s2 = s1 // copie indépendante
s2.numbers.append(10)

print(s1.numbers) // [1, 2, 3]
print(s2.numbers) // [1, 2, 3, 10]
```

➡️ Ici, `s1` et `s2` sont **deux copies distinctes**.  
Modifier `s2` ne change pas `s1`, car la structure est **copiée** en mémoire.  
C’est ce qu’on appelle la **sémantique de valeur**.

---

#### 🧩 Version `class` → Type **référence**

Les classes, au contraire, **ne sont pas copiées** :  
elles sont **référencées**.  
Plusieurs variables peuvent donc **pointer vers la même instance**.

```swift
let c1 = Calculator(numbers: [1, 2, 3], operation: "add")
let c2 = c1 // référence partagée
c2.numbers.append(10)

print(c1.numbers) // [1, 2, 3, 10]
print(c2.numbers) // [1, 2, 3, 10]
```

➡️ Ici, `c1` et `c2` **désignent la même instance** en mémoire.  
Modifier l’un **modifie aussi l’autre**, car la classe est **passée par référence**.  
C’est ce qu’on appelle la **sémantique de référence**.

---

### 🧠 À retenir

| Type | Transmission | Copie ou référence ? | Effet sur les modifications |
|------|---------------|----------------------|------------------------------|
| `struct` | Par valeur | Copie indépendante | Les changements ne se propagent pas |
| `class` | Par référence | Même instance partagée | Toute modification affecte toutes les références |

> 💡 **En résumé :**
> - Une `struct`, c’est comme un **duplicata complet du calculateur**.  
> - Une `class`, c’est comme **deux télécommandes qui pilotent la même machine**.

---

## 5. Comparaison d’objets de type `class` avec `===`

### ⚖️ `==` vs `===`

| Opérateur | Signification | Applicable à |
|------------|----------------|----------------|
| `==` | Compare les **valeurs** des propriétés (égalité logique) | `struct`, `enum`, `class` (si `Equatable`) |
| `===` | Compare les **identités d’instances** (égalité de référence mémoire) | `class` uniquement |

### Exemple complet :

```swift
class Personne {
    var nom: String
    init(nom: String) {
        self.nom = nom
    }
}

let p1 = Personne(nom: "Alice")
let p2 = Personne(nom: "Alice")
let p3 = p1

print(p1 === p2) // false → instances différentes
print(p1 === p3) // true  → même instance
```

### Pour comparer les valeurs (`==`)

```swift
class Personne: Equatable {
    var nom: String
    init(nom: String) {
        self.nom = nom
    }

    static func == (lhs: Personne, rhs: Personne) -> Bool {
        return lhs.nom == rhs.nom
    }
}

let a = Personne(nom: "Alice")
let b = Personne(nom: "Alice")
let c = a

print(a == b)   // true  → même valeur
print(a === b)  // false → instances différentes
print(a === c)  // true  → même instance
```

---

### Visualisation mémoire

| Variable | Instance mémoire | Nom | Résultat |
|-----------|------------------|-----|-----------|
| `a` | 0x1001 | Alice | |
| `b` | 0x1002 | Alice | `a === b` → `false` |
| `c` | 0x1001 | Alice | `a === c` → `true` |

💡 `==` compare les **valeurs** ; `===` compare les **références**.

---

## 6. Résumé général

| Utiliser… | Quand… |
|------------|--------|
| 🧱 `struct` | Données simples, indépendantes, copiées entre contextes. |
| 🧩 `class` | Identité, héritage, état partagé, ou interopérabilité Objective-C. |

> 💡 **Règle d’or Swift** : utilisez toujours `struct` par défaut, et optez pour `class` seulement si nécessaire.
