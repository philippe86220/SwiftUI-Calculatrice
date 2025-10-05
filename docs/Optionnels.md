---

## 📌 Aide-mémoire Swift : les optionnels

Pour éviter les crashs potentiels lorsqu’une valeur est manquante ou inadaptée (par exemple lors d’une conversion de texte en nombre), **Swift utilise les Optionnels** pour sécuriser l’exécution du code.

---

## 🌿 Qu’est-ce qu’un optionnel ?

En Swift, **l’absence de valeur** est représentée par le mot-clé spécial `nil`.  
👉 Ce n’est **pas** la même chose que `0`, la chaîne vide `""`, ou `NULL` en C.

En résumé, il existe deux types de valeurs en Swift :

- **Types réguliers** (non optionnels) → doivent toujours contenir une valeur valide.  
- **Types optionnels** → peuvent contenir une valeur ou `nil`.

La différence se marque en ajoutant un **`?` après le type** :

```swift
var entierNormal: Int = 25      // type régulier
var entierOptionnel: Int? = 25  // type optionnel
```
Un optionnel est en réalité un conteneur (wrapper) qui peut soit :
- contenir une valeur du type indiqué,
- soit contenir nil.

```swift
print(entierOptionnel)  // Optional(25)
print(entierNormal)     // 25
```
---
## 📦 Déballer (unwrap) un optionnel :

On ne peut pas utiliser directement une valeur optionnelle.
Il faut d’abord la “déballer” — c’est-à-dire sortir la valeur du conteneur.
Deux méthodes principales :
- if let
- guard let

## 🟦 1. if let — déballage local

```swift
if let nomConstante = valeurOptionnelle {
    // code si valeurOptionnelle ≠ nil
}
```

🔸 Comment ça fonctionne :
1. Swift vérifie si valeurOptionnelle contient une valeur.
2. Si oui, la valeur est déballée et affectée à nomConstante.
3. Le code dans les accolades est exécuté.
4. Si valeurOptionnelle est nil, le bloc if est ignoré.
    
👉 Attention : la constante créée (nomConstante) n’est disponible que dans le bloc if.

Il est aussi possible de :
- Déballer plusieurs optionnels dans un même if let (séparés par des virgules),
- Ajouter des conditions booléennes supplémentaires.

🧪 Exemple :
```swift
let valeurOptionnelle1: String? = "bonjour"
let valeurOptionnelle2: String? = nil

if let nomConstante = valeurOptionnelle1 {
    print("valeur déballée : \(nomConstante)")
} else {
    print("pas de valeur disponible")
}

if let nomConstante = valeurOptionnelle2 {
    print("valeur déballée : \(nomConstante)")
} else {
    print("pas de valeur disponible")
}
```
Sortie :
```swift
valeur déballée : bonjour
pas de valeur disponible
```
ℹ️ **Remarquez l’utilisation de = au lieu de == avec un if** :  
ici, on ne compare pas deux valeurs, on effectue une affectation conditionnelle.  
Si la valeur existe, elle est déballée et assignée à la constante temporaire.

## 🟨 2. guard let — déballage anticipé

```swift
guard let nomConstante = valeurOptionnelle else {
    // bloc exécuté si valeurOptionnelle == nil
    return
}
```
🔸 Comment ça fonctionne :
1. Swift vérifie si valeurOptionnelle contient une valeur.
2. Si oui, la valeur est déballée et affectée à nomConstante.  
→ Elle est alors disponible dans tout le bloc englobant, pas seulement dans guard.
3. Si valeurOptionnelle est nil, le bloc else s’exécute et on quitte la portée (souvent avec return).

   
🧪 Exemple :
```swift
let monNom: String? = "Philippe"
let autreNom: String? = nil

func saluer(_ nom: String?) {
    guard let nomDéballé = nom else {
        print("Aucun nom fourni")
        return
    }
    print("Bonjour, \(nomDéballé) !")
}

saluer(monNom)     // Bonjour, Philippe !
saluer(autreNom)   // Aucun nom fourni
```
ℹ️ Bien que if let et guard let soient principalement utilisés pour déballer des optionnels,  
ils peuvent aussi servir à réaliser des affectations conditionnelles plus générales.  
A partir de Swift 5.7, if let et guard let ont été étendus pour permettre de vérifier des conditions simples,  
pas uniquement de déballer des optionnels.

```swift
var x: Int? = 5

// Optionnel classique
if let valeur = x {
    print(valeur)
}

// Depuis Swift 5.7 : toute expression booléenne peut être testée
if let test = (2 + 2 == 4) ? "OK" : nil {
    print(test)  // OK
}
```

```swift
func division(_ a: Int, _ b: Int) {
    guard let resultat = (b != 0) ? Double(a) / Double(b) : nil else {
        print("Division par zéro interdite")
        return
    }
    print("Résultat : \(resultat)")
}

division(10, 2)  // Résultat : 5.0
division(10, 0)  // Division par zéro interdite

```


## 🪄 3. L’opérateur de coalescence nil : ??
Cet opérateur permet :
- d’utiliser la valeur de l’optionnel si elle existe,
- ou une valeur par défaut si l’optionnel est nil.
```swift
valeurOptionnelle ?? valeurParDefaut
```

🧪 Exemple :
```swift
let monNom: String? = "Philippe"
let autreNom: String? = nil

func saluer(_ nom: String) {
    print("Bonjour, \(nom) !")
}

saluer(monNom ?? "inconnu")    // Bonjour, Philippe !
saluer(autreNom ?? "inconnu")  // Bonjour, inconnu !
```

## ⚠️ 4. Le déballage forcé ! (à éviter)
```swift
let monNom: String? = "Philippe"

func saluer(_ nom: String) {
    print("Bonjour, \(nom) !")
}

saluer(monNom!)   // Bonjour, Philippe !
```

🚨 Si monNom est nil, cette opération provoque un crash.  
À réserver uniquement aux cas où vous êtes absolument certain qu’il y a une valeur.


## 🧰 5. Optionnels implicitement déballés (String!)
```swift
var monNom: String! = "Philippe"

func saluer(_ nom: String) {
    print("Bonjour, \(nom) !")
}

saluer(monNom)   // Bonjour, Philippe !

monNom = nil
// saluer(monNom) // ⚠️ Crash si nil !
```
👉 Un optionnel implicitement déballé se comporte comme une variable normale,  
mais provoque un crash s’il devient nil. À utiliser avec prudence.



📌 En résumé

| Méthode             | Sécurité   | Utilisation typique                         |
| ------------------- | ---------- | ------------------------------------------- |
| `if let`            | ✅ sûre     | Vérifications ponctuelles                   |
| `guard let`         | ✅ sûre     | Préconditions au début d’une fonction       |
| `??`                | ✅ sûre     | Valeurs par défaut                          |
| `!` (forced unwrap) | ❌ risquée  | Cas très particuliers                       |
| `String!`           | ⚠️ moyenne | Variables toujours censées avoir une valeur |

---

## 🔗 Le chaînage optionnel `?.`

Le chaînage optionnel permet d'accéder à une valeur imbriquée dans plusieurs niveaux d'optionnels, tout en s'arrêtant automatiquement au premier `nil` rencontré.

```swift
struct Naissance {
    var jour: Int
    var annee: Int
}

struct Personne {
    var nom: String
    var naissance: Naissance?
}

var p1: Personne? = Personne(nom: "Philippe", naissance: Naissance(jour: 4, annee: 1964))
var p2: Personne? = Personne(nom: "Inconnue", naissance: nil)
var p3: Personne? = nil

print(p1?.naissance?.annee) // Optional(1964)
print(p2?.naissance?.annee) // nil
print(p3?.naissance?.annee) // nil


