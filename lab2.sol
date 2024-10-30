// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Rock_Paper_Scissors {
    address public winner;
    address public player1;
    address public player2;
    bytes32 public hashed_choice1;
    bytes32 public hashed_choice2;
    string public choice1;
    string public choice2;

    enum Choice { Rock, Paper, Scissors }
    mapping(string => Choice) choice_mapping;

    constructor() {
        choice_mapping["rock"] = Choice.Rock;
        choice_mapping["paper"] = Choice.Paper;
        choice_mapping["scissors"] = Choice.Scissors;
        winner = address(0);
        player1 = address(0);
        player2 = address(0);
        choice1 = "";
        choice2 = "";
    }
    
    event game_result(string result);

    modifier free_place() {
        require(player1 == address(0) || player2 == address(0), "Both players are set");
        _;
    }

    modifier player_check() {
        require(msg.sender == player1 || msg.sender == player2, "You are not a player");
        _;
    }

    function join() public free_place {
        if (player1 == address(0)) {
            player1 = msg.sender;
        }
        else {
            if (player2 == address(0)) {
                player2 = msg.sender;
            }
        }
    }

    function get_hash(string memory choice, string memory salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(choice, salt));
    }

    function set_hashed_choice(bytes32 hashed_choice) public {
        if (msg.sender == player1) {
            hashed_choice1 = hashed_choice;
        }
        else {
            hashed_choice2 = hashed_choice;
        }
    }

    function reveal_choice(string memory choice, string memory salt) public returns (string memory) {
        if (msg.sender == player1 && keccak256(abi.encodePacked(choice, salt)) == hashed_choice1) {
            choice1 = choice;
            return "choice1 is revealed";
        }
        else if (msg.sender == player2 && keccak256(abi.encodePacked(choice, salt)) == hashed_choice2) {
            choice2 = choice;
            return "choice2 is revealed";
        }
        else {
            return "Some troubles";
        }
    }

    function play() public player_check{

        if (bytes(choice1).length != 0 && bytes(choice2).length != 0) {
            Choice player1_choice = choice_mapping[choice1];
            Choice player2_choice = choice_mapping[choice2];
        
            if (player1_choice == Choice.Rock && player2_choice == Choice.Scissors ||
                player1_choice == Choice.Paper && player2_choice == Choice.Rock ||
                player1_choice == Choice.Scissors && player2_choice == Choice.Paper) {
                winner = player1;
                emit game_result("Player1 won");
            }
            else {
                winner = player2;
                emit game_result("Player2 won");
            }
        }
        emit game_result("That's all");
    }
}