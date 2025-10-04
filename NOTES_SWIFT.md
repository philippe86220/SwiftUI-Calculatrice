---

## 📌 Aide-mémoire Swift : les optionnels

Les optionnels (`?`) permettent d'indiquer qu'une variable peut contenir une valeur ou être `nil`.  
Cela évite de nombreux crashs liés aux pointeurs nuls.  
Quelques rappels rapides :

- `Int?` → peut être un entier ou `nil`
- `if let` → déballage local
- `guard let` → déballage anticipé, visible après le bloc
- `??` → opérateur de coalescence nulle (valeur par défaut)

Exemple :
```swift
let age: Int? = 12
let valeur = age ?? 0      // 12 si age a une valeur, sinon 0

