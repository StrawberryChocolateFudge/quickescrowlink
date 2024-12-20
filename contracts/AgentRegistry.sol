//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Escrow.sol";

//The agents need to register here. They can add a name and deploy their own Escrow contracts from here.

contract AgentRegistry {
    uint256 public index;
    mapping(uint256 => address) public agentAddress;

    mapping(address => string) public agentName;

    mapping(address => address) public agentEscrowContracts;

    address[] public allEscrowContracts;

    address public simpleTerms;

    constructor(address simpleTerms_) {
        index = 0;
        simpleTerms = simpleTerms_;
    }

    //This should deploy a new Escrow contract
    //Specify the fee the agent charges
    function registerAgent(string memory _agentName, uint256 fee) external {
        require(bytes(_agentName).length > 5, "Name too short");
        require(compareAgentNameTo(""), "Only one escrow per address");
        agentName[msg.sender] = _agentName;
        agentAddress[index] = msg.sender;
        index++;

        Escrow escrow = new Escrow(msg.sender, simpleTerms, fee);

        agentEscrowContracts[msg.sender] = address(escrow);
        allEscrowContracts.push(address(escrow));
    }

    function updateAgentName(string memory newName) external {
        require(compareAgentNameTo("") == false, "Name not found");
        agentName[msg.sender] = newName;
    }

    function compareAgentNameTo(string memory to) internal view returns (bool) {
        return
            keccak256(abi.encodePacked(agentName[msg.sender])) ==
            keccak256(abi.encodePacked(""));
    }

    function getAllEscrowContracts() external view returns (address[] memory) {
        return allEscrowContracts;
    }

    //Returns the name of the agent, the address of the contract and if the contract is deprecated
    function getContractAndNameByIndex(
        uint256 _index
    ) external view returns (string memory, address, bool) {
        return (
            agentName[agentAddress[_index]],
            agentEscrowContracts[agentAddress[_index]],
            Escrow(agentEscrowContracts[agentAddress[_index]]).isDeprecated()
        );
    }
}
