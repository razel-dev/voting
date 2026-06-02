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


## VotingPlus Enhancements

The project includes an enhanced version of the voting contract named VotingPlus.

Additional Features
Proposal Validation

- Prevents voters from submitting empty proposals.

require(
    bytes(description).length > 0,
    "Proposal cannot be empty"
);

Benefits:

Improves data quality
Prevents meaningless proposals
Enforces business rules
Duplicate Proposal Detection

- Prevents registering the same proposal multiple times.

require(
    !proposalExists(description),
    "Proposal already exists"
);

Benefits:

Avoids duplicate proposals
Improves vote readability
Prevents vote fragmentation
Proposal Lookup Helper

- A dedicated helper function scans all registered proposals and detects duplicates.

function proposalExists(
    string memory description
)
    private
    view
    returns (bool)

Implementation details:

Iterates through the proposals array
Uses keccak256() hashes to compare strings
Returns true if a matching proposal exists
Proposal Utilities
getProposalCount()

Returns the total number of registered proposals.

getProposal(uint256 proposalId)

Returns a proposal by its identifier.

Benefits:

Easier proposal consultation
Better transparency
Simplifies future front-end integration



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