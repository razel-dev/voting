# Voting Smart Contract

## Overview

Voting is a smart contract developed in Solidity that implements a complete voting workflow on Ethereum.

The contract allows an administrator to manage a whitelist of voters, collect proposals, organize a voting session, tally votes and publish the winning proposal.

The implementation follows a strict workflow to ensure the integrity of the voting process.

---

## Features

### Voter registration

The contract owner registers voters using their Ethereum address.

Only the contract owner can add voters to the whitelist.

Voter registration is only allowed during the `RegisteringVoters` phase.

### Proposal registration

Registered voters can submit proposals during the proposal registration phase.

Additional validations have been implemented:

* Empty proposals are rejected.
* Duplicate proposals are rejected.
* Proposal comparisons are case-insensitive.
* Multiple spaces are normalized.
* Selected punctuation is ignored during duplicate detection.

### Voting session

Registered voters can vote for a proposal.

Each voter can vote only once.

Votes can only be cast during the voting session.

### Vote tallying

Once voting is closed, the contract owner can tally the votes.

The proposal with the highest number of votes becomes the winner.

### Winner consultation

After tallying, anyone can retrieve the winning proposal.

### Tie detection

The contract provides a utility function allowing the identification of proposals tied for first place.

---

## Workflow

The contract follows the workflow below:

1. RegisteringVoters
2. ProposalsRegistrationStarted
3. ProposalsRegistrationEnded
4. VotingSessionStarted
5. VotingSessionEnded
6. VotesTallied

Each transition is controlled by the contract owner.

---

## Technical Design

### Voting Contract

The `Voting` contract contains:

* Voter registration management
* Proposal management
* Voting management
* Vote tallying
* Workflow management

### StringUtils Library

The project includes a reusable utility library named `StringUtils`.

The library provides a normalization function used to compare proposals consistently.

The normalization process:

* Converts uppercase ASCII characters to lowercase
* Removes leading spaces
* Removes trailing spaces
* Collapses multiple spaces into a single space
* Removes selected punctuation characters

Example:

```
"  Swimming Pool!!!  "
```

becomes

```
"swimming pool"
```

This prevents duplicates such as:

```
"Swimming Pool"
"SWIMMING POOL"
" swimming pool "
"Swimming Pool!!!"
```

from being considered different proposals.

---

## Gas Consumption Considerations

The proposal normalization process consumes additional gas because each proposal must be normalized before duplicate detection.

This design choice was intentionally made to prioritize:

* Data consistency
* User experience
* Prevention of semantic duplicates
* Simplicity of the smart contract

For the expected scale of this project, the additional gas cost remains acceptable.

### Possible Production Optimization

For a larger-scale application, normalization could be delegated to an off-chain backend service.

In such an architecture:

1. The backend normalizes proposal descriptions.
2. The backend computes a hash of the normalized value.
3. The smart contract stores or compares only the hash.

This approach would significantly reduce on-chain processing costs while preserving duplicate detection guarantees.

The current implementation deliberately keeps the normalization logic on-chain to ensure transparency, determinism and independence from external systems.

---

## Security Measures

The contract includes several protections:

* Owner-only administrative actions
* Workflow phase validation
* Duplicate voter prevention
* Duplicate proposal prevention
* Empty proposal prevention
* Single vote per voter
* Proposal existence validation
* Restricted proposal access to registered voters

---

## Public Functions

### Administration

* whitelistAdd(address voterAddress)
* startProposalRegistration()
* endProposalRegistration()
* startVotingSession()
* endVotingSession()
* tallyVotes()

### Voting

* addProposal(string description)
* setVote(uint256 proposalId)

### Consultation

* getWorkflowStatus()
* getWinner()
* getProposalCount()
* getProposal(uint256 proposalId)
* getTiedProposals()

---

## Technologies

* Solidity 0.8.35
* OpenZeppelin Ownable
* Foundry

---

## Author

Rafael Alcaniz
