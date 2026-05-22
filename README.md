# Voting

Smart contract de système de vote développé en Solidity avec Foundry.

## Description

Ce projet implémente un système de vote basé sur Ethereum.

Les électeurs sont enregistrés via une liste blanche d’adresses Ethereum et suivent un processus de vote structuré.

Le système permet :

- l’enregistrement des électeurs ;
- l’enregistrement de propositions ;
- le vote sur une proposition ;
- le calcul du gagnant.

Le vote est transparent :
- les utilisateurs whitelistés peuvent consulter les votes ;
- chaque électeur ne vote qu’une seule fois ;
- le gagnant est déterminé à la majorité simple.

---

## Fonctionnalités prévues

- Gestion d’une whitelist d’électeurs
- Gestion des propositions
- Gestion des états du vote
- Vote unique par électeur
- Comptabilisation des votes
- Détermination du gagnant
- Contrôle administrateur avec OpenZeppelin Ownable

---

## Stack technique

- Solidity
- Foundry
- OpenZeppelin
- GitHub Actions

---

## Workflow du vote

Deploy
↓
Enregistrement des électeurs
↓
Début enregistrement propositions
↓
Fin enregistrement propositions
↓
Début session de vote
↓
Fin session de vote
↓
Comptabilisation
↓
Consultation du gagnant



## Structure du projet

src/
→ smart contracts

test/
→ tests Foundry

script/
→ scripts de déploiement

lib/
→ dépendances

.github/
→ CI GitHub Actions
```

---

## Auteur

GitHub : @alcaniz