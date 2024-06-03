// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Member {
    // Variables de estado
    mapping(address => bool) public members;

    // Eventos
    event MemberAdded(address member);
    event MemberRemoved(address member);

    // Función para añadir un nuevo miembro
    function addMember(address _member) external {
        // Implementar
        emit MemberAdded(_member);
    }

    // Función para eliminar un miembro
    function removeMember(address _member) external {
        // Implementar 
        emit MemberRemoved(_member);
    }

    // Función para verificar si una dirección es miembro
    function isMember(address _address) external view returns (bool) {
        // Implementar 
        return false;
    }
}
