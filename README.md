# Voting Smart Contract

## Overview

Voting is a Solidity smart contract implementing a complete voting workflow on Ethereum.

The contract allows an administrator to manage a whitelist of voters, collect proposals, organize a voting session, tally votes and publish the winning proposal.

The implementation follows a strict workflow to ensure the integrity and transparency of the voting process.

The project was developed using Foundry and OpenZeppelin.

---

## Features

### Voter Registration

The contract owner registers voters using their Ethereum address.

Only the contract owner can add voters to the whitelist.

Voter registration is only allowed during the `RegisteringVoters` phase.

Protections implemented:

* Only owner can register voters.
* Duplicate voter registration is prevented.
* Registration is forbidden once the proposal phase has started.

---

### Proposal Registration

Registered voters can submit proposals during the proposal registration phase.

Additional validations have been implemented:

* Empty proposals are rejected.
* Duplicate proposals are rejected.
* Comparisons are case-insensitive.
* Multiple spaces are normalized.
* Selected punctuation characters are ignored during duplicate detection.

Examples considered identical:

```text
Swimming Pool
SWIMMING POOL
 swimming pool
Swimming Pool!!!
```

---

### Voting Session

Registered voters can vote for a proposal.

Rules enforced:

* Only registered voters may vote.
* Voting is only possible during the voting phase.
* Each voter can vote only once.
* Voting for a non-existing proposal is forbidden.

---

### Vote Tallying

Once voting is closed, the contract owner can tally the votes.

The proposal receiving the highest number of votes becomes the winner.

---

### Winner Consultation

After vote tallying, anyone can retrieve the winning proposal.

---

### Tie Detection

The contract provides a utility function allowing the identification of proposals tied for first place.

When no tie exists, an empty array is returned.

---

## Workflow

The voting process follows six phases:

1. RegisteringVoters
2. ProposalsRegistrationStarted
3. ProposalsRegistrationEnded
4. VotingSessionStarted
5. VotingSessionEnded
6. VotesTallied

Each transition is controlled by the contract owner.

Workflow transitions are tracked through the `WorkflowStatusChange` event.

---

## Technical Design

### Voting Contract

The `Voting` contract contains:

* Voter registration management
* Proposal registration management
* Voting management
* Vote tallying
* Workflow management
* Tie detection
* Winner retrieval

---

### StringUtils Library

The project includes a reusable utility library named `StringUtils`.

The library provides a normalization function used to compare proposals consistently.

The normalization process:

* Converts uppercase ASCII characters to lowercase
* Removes leading spaces
* Removes trailing spaces
* Collapses multiple spaces into a single space
* Removes selected punctuation characters:

```text
!
,
.
:
;
?
```

Example:

```text
"  Swimming Pool!!!  "
```

becomes:

```text
"swimming pool"
```

This prevents semantically identical proposals from being registered multiple times.

---

## Gas Consumption Considerations

The proposal normalization process consumes additional gas because every proposal must be normalized before duplicate detection.

This design choice was intentionally made to prioritize:

* Data consistency
* Better user experience
* Duplicate prevention
* Contract autonomy
* On-chain transparency

For the expected scale of this project, the additional gas cost remains acceptable.

### Possible Production Optimization

For a larger-scale application, normalization could be delegated to an off-chain backend service.

In such an architecture:

1. The backend normalizes proposal descriptions.
2. The backend computes a hash of the normalized value.
3. The smart contract stores or compares only the hash.

Benefits:

* Reduced gas consumption
* Faster proposal registration
* Better scalability

The current implementation intentionally keeps normalization on-chain to guarantee deterministic behavior and independence from external systems.

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
* Prevention of voting outside the voting session

---

## Public API

### Administration

```solidity
whitelistAdd(address voterAddress)
startProposalRegistration()
endProposalRegistration()
startVotingSession()
endVotingSession()
tallyVotes()
```

### Voting

```solidity
addProposal(string description)
setVote(uint256 proposalId)
```

### Consultation

```solidity
getWorkflowStatus()
getWinner()
getProposalCount()
getProposal(uint256 proposalId)
getTiedProposals()
```

---

## Events

The contract emits the following events:

```solidity
VoterRegistered(address voterAddress)
WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus)
ProposalRegistered(uint256 proposalId)
Voted(address voter, uint256 proposalId)
```

These events allow external applications and frontends to track voting activity efficiently.

---

## Testing

Unit tests were developed using Foundry.

The test suite validates:

### Voter Registration

* Successful voter registration
* Owner restriction
* Duplicate registration prevention
* Registration phase restriction
* Event emission

### Proposal Registration

* Proposal creation
* Proposal event emission
* Empty proposal rejection
* Duplicate proposal rejection
* Access control

### String Normalization

* Case normalization
* Space normalization
* Punctuation normalization

### Voting

* Successful voting
* Double voting prevention
* Invalid proposal rejection
* Voting phase validation
* Event emission

### Results

* Winner determination
* Winner retrieval restrictions
* Tie detection
* No-tie scenarios

### Test Results

```text
24 tests passed
0 failed
0 skipped
```

---

## Coverage Report

Coverage generated with:

```bash
forge coverage
```

Results:

| File            | Lines  | Statements | Branches | Functions |
| --------------- | ------ | ---------- | -------- | --------- |
| StringUtils.sol | 94.74% | 96.88%     | 71.43%   | 100.00%   |
| Voting.sol      | 94.38% | 96.55%     | 73.81%   | 86.67%    |
| Total           | 94.49% | 96.69%     | 73.47%   | 87.50%    |

The project exceeds the testing requirements of the assignment while maintaining a clear and maintainable codebase.

---

## Technologies

* Solidity 0.8.35
* OpenZeppelin Ownable
* Foundry
* Forge
* GitHub Actions (CI)

---

## Author

Rafael Alcaniz
