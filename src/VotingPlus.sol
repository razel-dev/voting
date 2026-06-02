// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Voting.sol";

/// @title VotingPlus
/// @author Rafael Alcaniz
/// @notice Enhanced voting contract with additional validations and utility functions
/// @dev Adds onlyVoter modifier, proposal validation and proposal getter functions

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
                keccak256(bytes(normalizeDescription(proposals[i].description)))
                    == keccak256(bytes(normalizeDescription(description)))
            ) {
                return true;
            }
        }

        return false;
    }

    /// @notice Normalizes a proposal description
    /// @param description Description to normalize
    /// @return Normalized description
    /// @dev Converts uppercase ASCII letters to lowercase
    function normalizeDescription(string memory description) private pure returns (string memory) {
        bytes memory data = bytes(description);

        for (uint256 i = 0; i < data.length; i++) {
            if (uint8(data[i]) >= 65 && uint8(data[i]) <= 90) {
                data[i] = bytes1(uint8(data[i]) + 32);
            }
        }

        return string(data);
    }

    /// @notice Adds a new proposal
    /// @param description The description of the proposal to be added
    /// @dev Validates that the proposal description is not empty before adding it to the proposals array
    /// @dev Checks for duplicate proposals by comparing the description with existing proposals to prevent adding the same proposal multiple times
    function addProposal(string memory description) public override {
        require(bytes(description).length > 0, "Proposal cannot be empty");

        require(!proposalExists(description), "Proposal already exists");

        super.addProposal(description);
    }

    /// @notice Returns the total number of proposals
    /// @return Total number of registered proposals
    /// @dev Returns the length of the proposals array to indicate how many proposals have been added
    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }

    /// @notice Returns a proposal by its identifier
    /// @param proposalId Identifier of the proposal
    /// @return Requested proposal
    /// @dev Validates that the proposal ID is within the bounds of the proposals array before returning the proposal
    function getProposal(uint256 proposalId) public view returns (Proposal memory) {
        require(proposalId < proposals.length, "Proposal does not exist");

        return proposals[proposalId];
    }
}
