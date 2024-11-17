// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBetting {
    address public owner; // Owner of the contract
    uint256 public betAmount; // Fixed bet amount
    address[] public participants; // Array of participants
    mapping(address => bool) public hasParticipated; // Tracks if an address has participated

    // Events
    event BetPlaced(address indexed participant);
    event WinnerSelected(address indexed winner, uint256 prize);

    // Constructor to set the owner and the bet amount
    constructor(uint256 _betAmount) {
        owner = msg.sender;
        betAmount = _betAmount;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function for participants to place bets
    function placeBet() public payable {
        require(msg.value == betAmount, "Incorrect bet amount");
        require(!hasParticipated[msg.sender], "You have already placed a bet");

        participants.push(msg.sender); // Add participant
        hasParticipated[msg.sender] = true; // Mark as participated

        emit BetPlaced(msg.sender);
    }

    // Function to select a winner and transfer the prize
    function selectWinner() public onlyOwner {
        require(participants.length > 0, "No participants to select a winner");

        // Pseudo-random winner selection (not secure for production)
        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty, participants.length))
        ) % participants.length;
        address winner = participants[randomIndex];

        // Transfer the entire contract balance to the winner
        uint256 prize = address(this).balance;
        (bool success, ) = winner.call{value: prize}("");
        require(success, "Transfer to winner failed");

        emit WinnerSelected(winner, prize);

        // Reset the game
        resetGame();
    }

    // Internal function to reset the game
    function resetGame() internal {
        for (uint256 i = 0; i < participants.length; i++) {
            hasParticipated[participants[i]] = false; // Reset participation
        }
        delete participants; // Clear participants array
    }

    // View function to get the list of participants
    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    // View function to get the contract's balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
