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

    /// @notice Adds a new proposal
    /// @param description The description of the proposal to be added
    /// @dev Validates that the proposal description is not empty before adding it to the proposals array
    function addProposal(string memory description) public override {
        require(bytes(description).length > 0, "Proposal cannot be empty");

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
