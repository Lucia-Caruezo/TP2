# Trabajo Práctico Número 2: Desarrollo de una DAO
Trabajo Práctico Número 2 de la materia Introducción a Blockchain, dictada durante el primer semestre de 2024 (Escuela de Negocios, Universidad Torcuato Di Tella), realizado por Lucia Caruezo, Ayumi Florencia Ito, y Luciano Pozzoli. 

## Tabla de Contenidos
- [Introducción](#introducción)
- [Contratos](#contratos)
- [Member](#member)
- [Admin](#admin)
- [DAO](#dao)
- [Deployment](#deployment)
  
## Introducción
Este proyecto implementa una DAO (Organización Autónoma Descentralizada) que actúa como un fondo común de inversión. La DAO se gestiona a través de tres contratos inteligentes: Member, Admin y DAO. Estos contratos automatizan el registro de miembros y administradores, la creación y votación de propuestas, y las elecciones internas para elegir al presidente y tesorero.

## Contratos

### Member
Permite a los usuarios registrarse como miembros de la DAO. Funciones principales: 
- `inviteMember():`
- `addMember(address _member, address daoAddress):` Permite que un nuevo miembro se registre si ha sido invitado y envía la cantidad específica de fondos al contrato DAO. 
- `removeMember(address _member):` Permite que un miembro abandone la DAO.
- `isMember(address _member):` Verifica si una dirección es miembro de la DAO.

### Admin
Extiende el contrato Member permitiendo a los miembros convertirse en administradores si cumplen ciertos requisitos adicionales. Funciones principales: 
- `addAdmin(address _admin,  address daoAddress):` Permite que un miembro se registre como administrador si cumple con los requisitos adicionales.
- `removeAdmin(address _admin):` Permite que un aministrador abandone la DAO.
- `isAdmin(address _admin):` Verifica si una dirección es administrador de la DAO.

### DAO
Gestiona las propuestas, votaciones, elecciones internas y movimientos de fondos. Funciones principales: 
- `createProposal(address _recipient, string _description, uint256 _amount):` Permite a un miembro crear una propuesta especificando el destinatario, descripción y monto a transferir.
- `voteOnProposal(uint256 _proposalId, bool _vote):` Permite a los miembros votar a favor o en contra de una propuesta.
- `countVotes(uint256 _proposalId):` Cuenta los votos al finalizar el plazo de votación y determina si la propuesta se aprueba o rechaza.
- `executeProposal(uint256 _proposalId):` Ejecuta la transferencia de fondos si la propuesta es aprobada.
- `initiateElection(string _position):` Inicia una elección para un cargo específico (presidente o tesorero).
- `voteForCandidate(uint256 _candidateId):` Permite a los administradores votar por un candidato para un cargo.
- `getProposalStatus(uint256 _proposalId):` Verifica el estado de una propuesta.
- `getDAOFunds():` Consulta el saldo de los fondos de la DAO.

## Deployment
Los contratos fueron desarrollados en Remix y deployados en la testnet de Sepolia. 
1. Deployamos el contrato Member ``
2. Deployamos el contrato Admin, que hereda del contrato Member ``
3. Deployamos el contrato DAO, que integra los contratos Member y Admin ``

`tests/:` Contiene los scripts de prueba para los contratos.
`scripts/:`Contiene los scripts de deploy y otros scripts auxiliares (para Hardhat).
`migrations/:` Contiene los scripts de migración (para Truffle).
