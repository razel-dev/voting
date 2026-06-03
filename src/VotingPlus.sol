// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Voting.sol";
import "./StringUtils.sol";

/// @title VotingPlus
/// @author Rafael Alcaniz
/// @notice Enhanced voting contract with additional validations and utility functions
/// @dev Uses StringUtils library for proposal normalization and duplicate detection
contract VotingPlus is Voting {
    /// @notice Restricts access to registered voters only
    /// @dev Checks if the sender is a registered voter before allowing function execution
    modifier onlyVoter() {
        require(voters[msg.sender].isRegistered, "Voter must be registered");

        _;
    }

    /// @notice Checks whether a proposal already exists
    /// @param description The proposal description to search for
    /// @return True if an identical proposal already exists, otherwise false
    /// @dev Compares normalized descriptions using keccak256 hashes because Solidity does not support direct string comparison
    function proposalExists(string memory description) private view returns (bool) {
        for (uint256 i = 0; i < proposals.length; i++) {
            if (
                keccak256(abi.encodePacked(StringUtils.normalize(proposals[i].description)))
                    == keccak256(abi.encodePacked(StringUtils.normalize(description)))
            ) {
                return true;
            }
        }

        return false;
    }

    /// @notice Adds a new proposal
    /// @param description The description of the proposal to be added
    /// @dev Validates that the proposal description is not empty
    /// @dev Prevents duplicate proposals using normalized comparison
    function addProposal(string memory description) public override {
        require(bytes(description).length > 0, "Proposal cannot be empty");

        require(!proposalExists(description), "Proposal already exists");

        super.addProposal(description);
    }

    /// @notice Returns the total number of proposals
    /// @return Total number of registered proposals
    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }

    /// @notice Returns a proposal by its identifier
    /// @param proposalId Identifier of the proposal
    /// @return Requested proposal
    /// @dev Validates that the proposal ID exists before returning the proposal
    function getProposal(uint256 proposalId) public view returns (Proposal memory) {
        require(proposalId < proposals.length, "Proposal does not exist");

        return proposals[proposalId];
    }

    /// @notice Returns the identifiers of proposals tied for the highest vote count
    /// @return Array of proposal IDs that are tied for first place
    /// @dev Returns an empty array when there is no tie
    function getTiedProposals() public view returns (uint256[] memory) {
        uint256 maxVoteCount = 0;

        // Recherche du score maximal
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVoteCount) {
                maxVoteCount = proposals[i].voteCount;
            }
        }

        uint256 tieCount = 0;

        // Comptage des propositions ayant le score maximal
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount == maxVoteCount) {
                tieCount++;
            }
        }

        // Pas d'ex æquo
        if (tieCount < 2) {
            return new uint256[](0);
        }

        uint256[] memory tiedProposals = new uint256[](tieCount);
        uint256 tieIndex = 0;

        // Remplissage du tableau des propositions ex æquo
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount == maxVoteCount) {
                tiedProposals[tieIndex] = i;
                tieIndex++;
            }
        }

        return tiedProposals;
    }
}
