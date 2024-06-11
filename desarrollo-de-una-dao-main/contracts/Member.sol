// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Member {
    // Variables de estado
    mapping(address => bool) public members;
    mapping(address => uint256) public joinDate;
    
    address public daoAddress;

    constructor(address _daoAddress) {
        daoAddress=_daoAddress;
    }

    // Eventos
    event MemberAdded(address member);
    event MemberRemoved(address member);

    //modificador
    modifier onlyMember(){
        require (members[msg.sender], "Solo los miembros pueden realizar esta accion.");
        _;
    }

    // Función para añadir un nuevo miembro
    function addMember(address _member) external payable onlyMember {
        // Implementar
        require(!members[_member], "El miembro ya esta registrado.");
        require(msg.value >=1 ether, "Debe depositar al menos 1 ETH");
       
        //Transferir los fondos a la DAO
        payable(daoAddress).transfer(msg.value);

        members[_member]=true;
        joinDate[_member] = block.timestamp;
        emit MemberAdded(_member);
    }

    // Función para eliminar un miembro
    function removeMember(address _member) external onlyMember {
        // Implementar
        require(members[_member], "El miembro no esta registrado.");
        members[_member]=false;
        emit MemberRemoved(_member);
    }

    // Función para verificar si una dirección es miembro
    function isMember(address _address) external view returns (bool) {
        // Implementar 
        return members[_address];
    }
}
