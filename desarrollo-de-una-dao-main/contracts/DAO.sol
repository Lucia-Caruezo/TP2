// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "/Member.sol";
import "/Admin.sol";

contract DAO {
    // Struct para una Propuesta
    struct Proposal {
        address payable recipient; //Protocolo que recibe el financiamiento
        uint256 amount; //Monto que va a recibir el protocolo
        string category; //Dependiendo del monto, puede ser riesgosa o moderada
        uint256 deadline; //Fecha límite de votación
        uint256 votesFor; //Votos a favor de la propuesta
        uint256 votesAgainst; //Votos en contra de la propuesta
        bool approved; //True si ya fue aprobada
        bool executed; //True cuando fue ejecutada
        mapping(address => bool) voted; //Registro de si los miembros votaron
    }
    // Struct para las Elecciones Internas
    struct Election {
        string position; //Posición a la que se postula al miembro: Presidente (Chairperson) o Tesorero (Treasurer)
        address candidate; //Miembro que se postula, el candidato
        uint256 deadline; //Fecha límite de la eleccion
        uint256 votesFor; //Votos a favor del candidato
        uint256 votesAgainst; //Votos en contra del candidato
        bool executed; //True cuando fue ejecutada
        mapping(address => bool) voted; //Registro de si los miembros votaron
    }

    // Variables de estado
    address public chairperson;
    address public treasurer;
    mapping(uint256 => Proposal) internal proposals;
    mapping(uint256 => Election) internal elections;
    uint256 public proposalCount;
    uint256 public electionCount;
    uint256 public funds; 
    // Para usar los datos del contrato
    Member public MemberContract; 
    Admin public AdminContract;

    // Eventos de Propuestas
    event ProposalCreated(uint256 proposalId, address recipient, uint256 amount, string category, uint256 deadline);
    event VoteForProposal(address voter, uint256 proposalId, bool support);
    event ProposalApproved(uint256 proposalId);
    event ProposalExecuted(uint256 proposalId);
    // Eventos de Fondos
    event FundsWithdrawn(address to, uint256 amount);
    event FundsDeposited(address from, uint256 amount);
    // Eventos de Elecciones Internas 
    event ElectionStarted(string position, uint256 deadline, address candidate);
    event VoteForElection(address voter, address candidate, bool support);
    event ElectionExecuted(address candidate, string position);

    //  // Iniciamos con el creador como presidente y tesorero
    constructor(address _MemberAddress, address _AdminAddress) {
        chairperson = msg.sender;
        treasurer = msg.sender;
        MemberContract = Member(_MemberAddress);
        AdminContract = Admin(_AdminAddress);
    }

    // Modificadores
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Solo el presidente puede realizar esta accion");
        _;
    }

    modifier onlyTreasurer() {
        require(msg.sender == treasurer, "Solo el tesorero puede realizar esta accion");
        _;
    }

    modifier onlyMember(){
        require (MemberContract.isMember(msg.sender), "Solo los miembros pueden realizar esta accion.");
        _;
    }

       modifier onlyAdmin() {
        require(AdminContract.isAdmin(msg.sender), "Solo los administradores pueden realizar esta accion");
        _;
    }


    // Función para crear una nueva propuesta 
    function createProposal(address payable _recipient, uint256 _amount) external onlyMember {
        require(_amount>0, "El monto propuesto debe ser positivo.");
        require(_amount<=funds, "El monto propuesto excede los fondos disponibles.");

        Proposal storage newProposal = proposals[proposalCount];
        newProposal.recipient = _recipient;
        if (_amount>(funds/2)) { 
        // Si la propuesta supera el 50% de los fondos, su votación tendrá duración de 5 días y se considera la propuesta como riesgosa
            newProposal.deadline = block.timestamp + 5 days; 
            newProposal.category = "Risky";
        } else {
        // En caso contrario, su votación tendrá duración de 2 días y se considera la propuesta como moderada.
            newProposal.deadline = block.timestamp + 2 days; 
            newProposal.category = "Moderate";
        }
        newProposal.amount = _amount;
        newProposal.approved = false;
        newProposal.executed = false;
        emit ProposalCreated(proposalCount, _recipient, _amount, newProposal.category, newProposal.deadline);
        proposalCount++;
        }

    // Función para votar en una propuesta
    function voteProposal(uint256 _proposalId, bool _support) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "La votacion ha terminado");
        require(!proposal.voted[msg.sender], "El miembro ya ha votado");

        proposal.voted[msg.sender] = true;

        if (_support) {
            if (AdminContract.isAdmin(msg.sender)) {
                proposal.votesFor +=2; //Voto doble para administradores
            } else {
                proposal.votesFor++;
            }
        } else {
            if (AdminContract.isAdmin(msg.sender)) {
                proposal.votesAgainst +=2; //Voto doble para administradores
            } else {
                proposal.votesAgainst++;
            }
        }
        emit VoteForProposal(msg.sender, _proposalId, _support);
    }

    // Funcion para el recuento de votos y determinar si se aprueba o no
    function countVotes(uint256 _proposalId, bool _support) external onlyChairperson {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.deadline, "La votacion aun no ha terminado");
        require(!proposal.approved, "La propuesta ya ha sido aprobada");
        if (proposal.votesFor > proposal.votesAgainst) {
            proposal.approved = true; // Propuesta aprobada
        } else if (proposal.votesFor == proposal.votesAgainst) {
            if (_support) {
                proposal.approved = true; // Propuesta aprobada
            } else {
                proposal.approved = false; // Propuesta no aprobada
            }
        } else {
            proposal.approved = false; // Propuesta no aprobada
        }
        emit ProposalApproved(_proposalId);
    }

    // Función para ejecutar una propuesta
    function executeProposal(uint256 _proposalId) external onlyTreasurer {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "La propuesta ya ha sido ejecutada");
        require(proposal.approved, "La propuesta no ha sido aprobada");

        funds -= proposal.amount;
        proposal.recipient.transfer(proposal.amount);
        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
        emit FundsWithdrawn(proposal.recipient, proposal.amount);
    }

    // Función para iniciar una elección para presidente o tesorero
    function startElection(string memory _position, address _candidate) external onlyAdmin {
        require(AdminContract.isAdmin(_candidate), "El candidato a postular debe ser administrador.");
        Election storage newElection = elections[electionCount];
        newElection.position = _position;
        newElection.candidate = _candidate;
        newElection.deadline = block.timestamp + 5 days;
        newElection.executed = false;
        electionCount++;
        emit ElectionStarted(_position, newElection.deadline, _candidate);
    }

    // Función para votar a favor o en contra de un candidato
    function voteForCandidate(uint256 _electionID, bool _support) external onlyAdmin {
        Election storage election = elections[_electionID];
        require(block.timestamp < election.deadline, "La votacion ha terminado.");
        require(!election.voted[msg.sender], "El administrador ya ha votado.");
        election.voted[msg.sender] = true;

        if (_support) {
            election.votesFor++;
        } else {
            election.votesAgainst++;
        }
        emit VoteForElection(msg.sender, election.candidate, _support);
    }

    // Función para ejecutar la elección
    function executeElection(uint256 _electionID) external onlyAdmin {
        Election storage election = elections[_electionID];
        require(block.timestamp >= election.deadline, "La votacion aun no ha terminado.");
        require(election.votesFor > election.votesAgainst, "El candidato no ha recibido suficientes votos positivos.");

        if (keccak256(bytes(election.position)) == keccak256(bytes("chairperson"))) {
            require(election.candidate != treasurer, "El candidato ya es tesorero, no puede tener doble funcion");
            chairperson = election.candidate;
        } else if (keccak256(bytes(election.position)) == keccak256(bytes("treasurer"))) {
            require(election.candidate != chairperson, "El candidato ya es presidente, no puede tener doble funcion");
            treasurer = election.candidate;
        }
        emit ElectionExecuted(election.candidate, election.position);
    }

    // Función para depositar fondos, ya sea de colaboradores o protocolos que fueron exitosos
    function depositFunds() external payable {
        funds += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Función para verificar el estado de una propuesta
    function getProposalStatus(uint256 _proposalId) external view returns (string memory) {
        Proposal storage proposal = proposals[_proposalId];
        
        if (proposal.executed) {
            return "Aprobada y ejecutada";
        } else if (proposal.approved) {
            return "Aprobada pero no ejecutada";
        } else {
            return "No aprobada";
        }
    }

    // Función para obtener la información de una propuesta
    function getProposalInfo(uint256 _proposalId) external view returns (address recipient, uint256 amount, uint256 deadline, string memory category, bool approved, bool executed) {
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.recipient, proposal.amount, proposal.deadline, proposal.category, proposal.approved, proposal.executed);
    }

    // Función para obtener el balance de fondos
    function getFunds() external view returns (uint256) {
        return funds;
    }
}
