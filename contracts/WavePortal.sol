// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    mapping(address => uint) public waves_naive;

    uint256 private seed;

    /*
    * emit wave event
    */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
    Struct custom data type, customize what to hold inside of it
    */

    struct Wave {
        address waver; // address of waver
        string message; // message the user sent
        uint256 timestamp; // timestamp when the user waved
    }

    /*
    Lets me store and array of structs, can hold all of the waves!
    */

    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;


    constructor() payable {
        console.log("Yo yo, I am a contract and I am v smart");
    }

    // string mssage user will send from frontend!
    function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 15m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        waves_naive[msg.sender] += 1;
        console.log("%s has waved!", msg.sender);

        /*
        * store wave data in array
        */
        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
        * Generate a Pseudo random number between 0 and 100
        */
        uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %s", randomNumber);

        /*
        * set the generated, random number as the seed for the next wave
        */
        seed = randomNumber;

        if (randomNumber < 50) {
            console.log("%s won!", msg.sender);

            /*
            * messenger has won, release funds
            */
            uint256 prizeAmount = 0.00001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has!"
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);

    }

    function loseWave() public {
        totalWaves -= 1;
        waves_naive[msg.sender] -= 1;
        console.log("%s has reduced the number of waves", msg.sender);
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getWaverWaves() public view returns (uint) {
        console.log("Address %s has %d waves!", msg.sender, waves_naive[msg.sender]);
        return waves_naive[msg.sender];
    }
}