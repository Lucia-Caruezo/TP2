// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Member {
    // Variables de estado
    mapping(address => bool) public members;
    mapping(address => bool) public invitations;
    mapping(address => uint256) public joinDate;

    // Iniciamos con el creador como unico miembro
    constructor() {
        members[msg.sender];
    }

    // Eventos
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event MemberInvited(address member);

    // Modificador
    modifier onlyMember(){
        require (members[msg.sender], "Solo los miembros pueden realizar esta accion.");
        _;
    }

    // Funcion para invitar un nuevo miembro 
    function inviteMember(address _member) external onlyMember {
        require(!members[_member], "El miembro ya esta registrado.");
        invitations[_member]=true;
        emit MemberInvited(_member);
    }
    
    // Función para añadir un nuevo miembro
    function addMember(address _member) external payable {
        require(!members[_member], "El miembro ya esta registrado.");
        require(invitations[_member], "No ha sido invitado.");
        require(msg.value >=1 ether, "Debe depositar al menos 1 ETH");
       
        payable(daoAddress).transfer(msg.value); //Transferir los fondos a la DAO

        members[_member]=true;
        joinDate[_member] = block.timestamp;
        emit MemberAdded(_member);
    }

    // Función para eliminar un miembro
    function removeMember(address _member) external {
        require(members[_member], "El miembro no esta registrado.");
        require(msg.sender==_member, "Solo el miembro puede elegir abandonar la DAO"); //Para evitar eliminaciones arbitrarias
        members[_member]=false;
        members[_member]=false;
        emit MemberRemoved(_member);
    }

    // Función para verificar si una dirección es miembro
    function isMember(address _address) external view returns (bool) {
        return members[_address];
    }
}
