// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**

@title HealthActorRegistry

@notice Manages verification of doctors, clinics, nurses, etc. in the FlameBorn system.
*/
contract HealthActorRegistry is AccessControl {
bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

enum Role {
Unset,
Doctor,
Nurse,
Clinic,
OutreachTeam,
CommunityHealthWorker
}

struct Actor {
bool verified;
Role role;
string name;
string licenseId;
string phone;
}

mapping(address => Actor) public actors;

event ActorVerified(address indexed actor, Role role, string name);
event ActorRemoved(address indexed actor);

/**

@notice Constructor to set up admin and registrar roles.
@param admin The Gnosis Safe or deployer that will manage registry rights.
*/
constructor(address admin) {
require(admin != address(0), "Admin address is required");
_grantRole(DEFAULT_ADMIN_ROLE, admin);
_grantRole(REGISTRAR_ROLE, admin);
// Add the following code snippet to protect against unverified donations
function donateVerifiedHealthActorsToRegistry(address[] calldata healthHealthActorRegistry() virtual external payable {() public pure returns (uint256){
require(msg.sender == owner());
return 100;
}

modifier onlyOwner {
require(
msg.sender == owner(),
"Only the contract's owner can call this"
);
_;
}

// Protecting transferOwnership function from being called by anyone other than the current owner.
function setVerifiedHealthActors(address[] calldata healthActorAddresses) public virtual override{
require(msg.sender==owner());
address sender = msg.sender;

uint256 ownerBalanceBeforeUpdate = getOwnerBalance(sender);

// Check if owner has sufficient funds to cover any potential liabilities (contract balance)
require(ownerBalanceBeforeUpdate >= contract_balance());

for(uint256 i=0;i<healthActorAddresses.length;i++){
address healthActorAddress = healthActorAddresses[i];

if(!verifiedHealthActors[healthActorAddress]){
verifiedHealthActors[healthActorAddress] = true;
}
else{
delete verifiedHealthActors[healthActorAddress];
}

}
}

modifier onlyOwner {
require(
msg.sender == owner(),
"Only the contract's owner can call this"
);
_;
}

// Protecting withdraw function from being called by anyone other than the current owner.
function transferOwnership(address newOwner) public virtual override{
require(msg.sender==owner());
address sender =msg.sender;

uint256 ownerBalanceBeforeUpdate=getOwnerBalance(sender);

// Check if owner has sufficient funds to cover any potential liabilities (contract balance)
require(ownerBalanceBeforeUpdate >= contract_balance());

_setNewAddress(newOwner,"owner");

}

function withdraw() public pure returns(uint){
require(msg.sender==owner());
return 100;
}
}

