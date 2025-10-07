---

## 📌 Aide-mémoire Swift : les Protocoles et les Extensions 

---

## 1. Les Protocoles en Swift :

En Swift, un protocole agit comme un contrat (ou cahier des charges) que tout type peut choisir d’adopter. 
Il précise les propriétés et méthodes nécessaires pour remplir un rôle donné.  
Il décrit précisément ce qu’il faut savoir faire (méthodes) et ce qu’il faut posséder (propriétés) pour tenir un certain rôle.  
Le protocole ne donne pas les détails sur la façon dont ces choses doivent être faites : il se contente de dire ce qui est nécessaire.  
Ensuite, tout type qui annonce suivre ce protocole doit écrire son propre code pour chacune des méthodes et propriétés exigées par ce protocole.

👉 C’est comme une liste d’exigences que les types (classes, structures, énumérations) doivent respecter.

**Exemples :**

```swift
// Déclaration d’un protocole
protocol Animal {
    var nom: String { get }
    func parler()
}

// Une structure qui adopte le protocole
struct Chien: Animal {
    var nom: String

    func parler() {
        print("Ouaf ! Je m'appelle \(nom).")
    }
}

// Utilisation
let monChien = Chien(nom: "Rex")
monChien.parler() // Affichera : Ouaf ! Je m'appelle Rex.
```
Dans cet exemple :
•	Le protocole Animal définit une propriété (nom) et une méthode (parler).
•	La structure Chien dit qu’elle respecte le protocole Animal et doit donc fournir le code pour ces deux éléments.
•	Grâce à cette structure, on peut créer un chien et lui faire « parler » selon ce qui est prévu par le protocole.

---
📌 autre exemple simple : un protocole NomComplet
```swift
protocol NomComplet {
    var nomComplet: String { get }
}

```
👉 Ici, tout type qui adopte NomComplet doit fournir une propriété calculée nomComplet.

✅ Utilisation avec une structure :

```swift
struct Personne: NomComplet {
    var prenom: String
    var nom: String

    var nomComplet: String {
        return "\(prenom) \(nom)"
    }
}

let p = Personne(prenom: "Marie", nom: "Dupont")
print(p.nomComplet)   // ➡️ "Marie Dupont"
```

👉 Personne respecte le contrat : elle fournit bien la propriété nomComplet.


## 🧭 quelle utilité ?

Un protocole permet de décrire un ensemble d’exigences communes que plusieurs types peuvent partager, ce qui rend le code plus flexible et cohérent.  
En d’autres termes, c’est une façon de dire :  
« Peu importe qui tu es (structure, classe, énumération),  
si tu respectes ce protocole,  
je sais que tu sais faire certaines choses. »

🎯 **Pourquoi utiliser un protocole ?**

- ✅ **Uniformité des interfaces**  
Les protocoles garantissent que plusieurs types offrent les mêmes méthodes ou propriétés,  
ce qui permet de les utiliser de manière interchangeable sans connaître leur nature exacte.

- 🔁 **Flexibilité et réutilisation**  
On peut écrire des fonctions ou des méthodes qui acceptent en paramètre n’importe quel type conforme à un protocole.  
Cela favorise la programmation générique et évite la duplication de code.

- 🧩 **Découplage du code**  
Les protocoles réduisent la dépendance à des types précis.  
Le code devient ainsi plus modulaire, plus facile à tester, à faire évoluer ou à étendre.

---

📝 Exemple simple :
Imaginons qu’on veuille afficher des informations pour différents objets comme un chien 🐶 ou une voiture 🚗.
S’ils adoptent tous un protocole Affichable qui définit une méthode afficher(), on peut les traiter de la même manière :

```swift
protocol Affichable {
    func afficher()
}

struct Chien: Affichable {
    func afficher() { print("Je suis un chien.") }
}

struct Voiture: Affichable {
    func afficher() { print("Je suis une voiture.") }
}

// Fonction générique qui accepte n'importe quel 'Affichable'
func afficherInfo(_ item: Affichable) {
    item.afficher()
}

afficherInfo(Chien())    // ➡️ Je suis un chien.
afficherInfo(Voiture())  // ➡️ Je suis une voiture.
```
👉 Grâce au protocole, afficherInfo(_:) peut fonctionner avec n’importe quel type qui respecte Affichable,  
sans avoir besoin de connaître sa structure interne.

✨ En résumé :
Les protocoles permettent de :
- définir un contrat clair entre différents types,
- uniformiser leurs interfaces,
- rendre le code flexible, réutilisable et évolutif.

## 2. Les Extensions en Swift :

Une extension permet d’ajouter des fonctionnalités à un type déjà existant,  
sans modifier son code d’origine.  
C’est très pratique pour enrichir les types Swift (ou vos propres types).

📌 Exemples simples : extensions de `String` et de `Int`

```swift
extension String {
    func entourerAvecÉtoiles() -> String {
        return "🌟 \(self) 🌟"
    }
}

let texte = "Bonjour"
print(texte.entourerAvecÉtoiles())   // ➡️ 🌟 Bonjour 🌟
```

```swift
// On étend le type Int pour ajouter une nouvelle propriété calculée
extension Int {
    var carre: Int {
        return self * self
    }
}

// Utilisation de cette extension
let nombre = 5
print(nombre.carre)  // Affiche : 25
```
Dans ce dernier exemple, on ajoute au type `Int` une propriété calculée `carre` qui renvoie le carré du nombre.  
Grâce à cette extension,  
on peut écrire `nombre.carre` comme si c’était une propriété native de `Int`,  
sans modifier le code original du type `Int`.

## 🧩 3. Combiner Protocole + Extension

👉 **Très courant en Swift :**

- **On définit un protocole pour poser un contrat**
- **Puis on écrit une extension du protocole pour donner une implémentation par défaut.**

📌 Exemple : protocole Saluer

```swift
protocol Saluer {
    func direBonjour()
}
```
→ Extension avec comportement par défaut:
```swift
extension Saluer {
    func direBonjour() {
        print("Bonjour 👋")
    }
}
```
👉 Tout type qui adopte Saluer a automatiquement cette version de direBonjour()
… sauf s’il la remplace.

→ Adoption dans une structure
```swift
struct Étudiant: Saluer {}

let e = Étudiant()
e.direBonjour()   // ➡️ Bonjour 👋
```
👉 L’étudiant n’a rien eu besoin d’écrire : il profite de l’implémentation fournie par l’extension !

✨ 4. Exemple concret un peu plus parlant
Supposons qu’on veuille créer un petit système où différents objets peuvent s’afficher joliment :
```swift
protocol Affichable {
    func afficher()
}

extension Affichable {
    func afficher() {
        print("Je suis un objet affichable 📝")
    }
}

struct Voiture: Affichable {
    var marque: String
    func afficher() {
        print("🚗 Marque : \(marque)")
    }
}

struct Maison: Affichable {
    var adresse: String
    // ne redéfinit pas afficher → utilisera celle par défaut
}

let v = Voiture(marque: "Tesla")
let m = Maison(adresse: "12 rue des Lilas")

v.afficher()   // ➡️ 🚗 Marque : Tesla
m.afficher()   // ➡️ Je suis un objet affichable 📝
```
👉 Ici :
- Voiture fournit sa propre version personnalisée
- Maison hérite du comportement par défaut

📝 Résumé :

| Concept                   | Sert à...                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------ |
| **Protocole**             | Définir une liste d'exigences (méthodes/propriétés) que les types doivent respecter  |
| **Extension**             | Ajouter de nouvelles fonctions ou propriétés à un type existant                      |
| **Protocole + Extension** | Offrir des comportements par défaut tout en laissant la possibilité de personnaliser |


