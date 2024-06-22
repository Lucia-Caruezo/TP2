// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "/Member.sol";

contract Admin is Member {
    mapping(address => bool) public admins;

    constructor(address _daoAddress) Member(_daoAddress) {
        admins[msg.sender];
    }

    event AdminAdded(address admin);
    event AdminRemoved(address admin);

    function addAdmin(address _admin) external payable onlyMember {
        require(!admins[_admin], "El administrador ya esta registrado");
        /// modificar para que 
        require(joinDate[_admin]>= block.timestamp - 5 days, "El miembro no cumple con la duracion requerida para ser administrador");
        require(msg.value >= 2 ether, "Debe depositar al menos 2 ETH");

        //Transferir los fondos a la DAO
        payable(daoAddress).transfer(msg.value);

        admins[_admin] = true;
        members[_admin] = true;  // Los administradores también son miembros
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyMember {
        require(admins[_admin], "El administrador no existe");
        admins[_admin] = false;
        members[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function isAdmin(address _address) public view returns (bool) {
        return admins[_address];
    }
}
