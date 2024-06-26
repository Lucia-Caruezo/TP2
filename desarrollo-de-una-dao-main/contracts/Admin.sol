// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "/Member.sol";

contract Admin is Member {
    mapping(address => bool) public admins;

    // CHEQUEAR Agregamos al creador como administrador
    constructor() Member() {
        admins[msg.sender];
    }

    // Eventos
    event AdminAdded(address admin);
    event AdminRemoved(address admin);

    // Funcion para pasar a ser administrador
    function addAdmin(address _admin) external payable onlyMember {
        require(!admins[_admin], "El administrador ya esta registrado");
        // El admin debe llevar por lo menos 5 dias como miembro
        require(joinDate[_admin]>= block.timestamp - 5 days, "El miembro no cumple con la duracion requerida para ser administrador");
        require(msg.value >= 2 ether, "Debe depositar al menos 2 ETH");

        payable(daoAddress).transfer(msg.value); //Transferir los fondos a la DAO

        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    //Funcion para abandonar la DAO
    function removeAdmin(address _admin) external {
        require(admins[_admin], "El administrador no existe");
        require(msg.sender==_admin, "Solo el admin puede elegir abandonar la DAO"); //Para evitar eliminaciones arbitrarias
        admins[_admin] = false;
        members[_admin] = false;
        emit AdminRemoved(_admin);
    }

    // Función para verificar si una dirección es administrador
    function isAdmin(address _address) public view returns (bool) {
        return admins[_address];
    }
}
