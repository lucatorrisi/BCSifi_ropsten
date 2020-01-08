pragma solidity ^0.5.7;

contract ArchiveCertification{

  struct processAction{
    address from;
    string action;
    string latitude;
    string longitude;
    uint256 timestamp;
  }

  struct Certificate{
    address process_owner;
    string name;
    string description;
    processAction[] process_data;
    uint256 unique_identifier;
  }

  address payable contract_owner;
  uint certificateCounter;
  mapping (uint => Certificate) public certificates;

  // modifiers
  modifier contractOwner() {
    require(msg.sender == contract_owner, "Error setting owner");
    _;
  }

  // constructor
  constructor () public {
    contract_owner = msg.sender;
  }

  function getLastBlockTimestamp() public view returns (uint) {
    return  block.timestamp;
  }


  function getContractOwner() public view returns (address){
    return contract_owner;
  }


  // deactivate the contract
  function kill() public contractOwner {
    selfdestruct(contract_owner);
  }

  // events
  event LogSignCertificate(
    uint indexed _unique_identifier,
    address indexed _process_owner,
    string _name
  );

  // events
  event LogModifyCertificate(
    uint _unique_identifier,
    string _information
  );

  // events
  event LogModifyProcessOwner(
    address _newOwner,
    uint _unique_identifier
  );


  function signCertificate(address _process_owner, string memory _name,
  string memory _description, uint256 _unique_identifier) public contractOwner{

    certificates[_unique_identifier].process_owner = _process_owner;
    certificates[_unique_identifier].name = _name;
    certificates[_unique_identifier].description = _description;
    certificates[_unique_identifier].process_data.push (processAction(msg.sender,"Init", "0.0", "0.0", block.timestamp ));
    certificates[_unique_identifier].unique_identifier = _unique_identifier;


    emit LogSignCertificate(_unique_identifier, _process_owner, _name);
  }

  function getCertificate(uint _unique_identifier) public view returns (
    address, string memory, string memory, address, uint){

    require(certificates[_unique_identifier].unique_identifier == _unique_identifier, "Error getCertificate");

    return (certificates[_unique_identifier].process_owner, certificates[_unique_identifier].name, certificates[_unique_identifier].description, address(this), certificates[_unique_identifier].process_data.length);
  }

  function getProcessInfo(uint256 _unique_identifier, uint _processIndex) public view returns (address, string memory, string memory, string memory, uint256){
    require(certificates[_unique_identifier].unique_identifier == _unique_identifier, "Error getCertificateInfo");

    return (certificates[_unique_identifier].process_data[_processIndex].from,certificates[_unique_identifier].process_data[_processIndex].action, certificates[_unique_identifier].process_data[_processIndex].latitude,
      certificates[_unique_identifier].process_data[_processIndex].longitude, certificates[_unique_identifier].process_data[_processIndex].timestamp);
  }
  function modifyCertificate(uint256 _unique_identifier, string memory _information, string memory lat, string memory lon) public {
    require(msg.sender == certificates[_unique_identifier].process_owner,"Error modifyCertificate");

    certificates[_unique_identifier].process_data.push (processAction(msg.sender,_information, lat, lon, block.timestamp ));
    emit LogModifyCertificate(_unique_identifier, _information);
  }

  function modifyProcessOwner(uint256 _unique_identifier, address _newOwner, string memory lat, string memory lon) public {
    require(msg.sender == certificates[_unique_identifier].process_owner,"Error modifyProcessOwner");

    certificates[_unique_identifier].process_owner = _newOwner;
    bytes memory ownerAction = abi.encodePacked("Transfer of ownership to ");
    ownerAction = abi.encodePacked(ownerAction,addressToString(_newOwner));
    certificates[_unique_identifier].process_data.push (processAction(msg.sender,string(ownerAction), lat, lon, block.timestamp ));
    emit LogModifyProcessOwner(_newOwner, _unique_identifier);
  }

  function getCertificateOwner(uint256 _unique_identifier) public view returns (address){
    Certificate storage certificate = certificates[_unique_identifier];
    return certificate.process_owner;
  }

  function addressToString(address _addr) public pure returns(string memory)
  {
    bytes32 value = bytes32(uint256(_addr));
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(51);
    str[0] = '0';
    str[1] = 'x';
    for (uint256 i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
        str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    return string(str);
  }


}
