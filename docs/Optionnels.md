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
4.   Si valeurOptionnelle est nil, le bloc if est ignoré.
    
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
```swif
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

---

📌 En résumé

| Méthode             | Sécurité   | Utilisation typique                         |
| ------------------- | ---------- | ------------------------------------------- |
| `if let`            | ✅ sûre     | Vérifications ponctuelles                   |
| `guard let`         | ✅ sûre     | Préconditions au début d’une fonction       |
| `??`                | ✅ sûre     | Valeurs par défaut                          |
| `!` (forced unwrap) | ❌ risquée  | Cas très particuliers                       |
| `String!`           | ⚠️ moyenne | Variables toujours censées avoir une valeur |

