# Trabajo Práctico Número 2: Desarrollo de una DAO
Trabajo Práctico Número 2 de la materia Introducción a Blockchain, dictada durante el primer semestre de 2024 (Escuela de Negocios, Universidad Torcuato Di Tella), realizado por Lucia Caruezo, Ayumi Florencia Ito, y Luciano Pozzoli. 

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
  
## Introducción
Este proyecto implementa una DAO (Organización Autónoma Descentralizada) que actúa como un fondo común de inversión. La DAO se gestiona a través de tres contratos inteligentes: Member, Admin y DAO. Estos contratos automatizan el registro de miembros y administradores, la creación y votación de propuestas, y las elecciones internas para elegir al presidente y tesorero.

## Contratos
### Member
Permite a los usuarios registrarse como miembros de la DAO. Funciones principales: 
	•	addMember(address _member, uint256 _amount): Permite que un nuevo miembro se registre si ha sido invitado y envía la cantidad específica de fondos.
	•	isMember(address _member): Verifica si una dirección es miembro de la DAO.
	•	getMembers(): Devuelve la lista de todos los miembros registrados.



### Desarrollo y Deployment

Los contratos fueron desarrollados en Remix y deployados en la testnet de Sepolia. 
La DAO funciona con tres contratos principales: DAO, Member y Admin. 

`contracts/:` Contiene los smart contracts.

## Ejecutar Pruebas
Para ejecutar las pruebas (para Truffle o Hardhat):

```bash
truffle test
# o
npx hardhat test
```

## Deploy
Para deployar los contratos a una red local (para Truffle o Hardhat):

```bash
truffle migrate --network development
# o
npx hardhat run scripts/deploy.js --network localhost
```

Para Remix, pueden deployar los contratos directamente copiando los archivos DAO.sol y Member.sol en el editor de Remix.

## Estructura del Proyecto
`contracts/:` Contiene los smart contracts.
`tests/:` Contiene los scripts de prueba para los contratos.
`scripts/:`Contiene los scripts de deploy y otros scripts auxiliares (para Hardhat).
`migrations/:` Contiene los scripts de migración (para Truffle).
