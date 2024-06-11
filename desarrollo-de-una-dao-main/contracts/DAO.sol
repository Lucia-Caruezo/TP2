// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "/Member.sol";
import "/Admin.sol";

contract DAO {
    // Struct para una Propuesta
    struct Proposal {
        string description;
        uint256 deadline;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    struct Election {
        string position;
        address candidate;
        uint256 deadline;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    // Variables de estado
    address public chairperson;
    address public treasurer;
    mapping(uint256 => Proposal) internal proposals;
    mapping(uint256 => Election) internal elections;
    uint256 public proposalCount;
    uint256 public electionCount;
    uint256 private funds; //agrego fondos
    // para usar los datos del contrato
    Member public MemberContract; 
    Admin public AdminContract;

    // Eventos
    event ProposalCreated(uint256 proposalId, string description, uint256 deadline);
    event VoteForProposal(address voter, uint256 proposalId, bool support);
    event ProposalExecuted(uint256 proposalId);
    //para mover los fondos
    event FundsDeposited(address from, uint256 amount);
    event FundsWithdrawn(address to, uint256 amount);
    //elecciones
    event ElectionStarted(string position, uint256 deadline, address candidate);
    event VoteForElection(address voter, address candidate, bool support);
    event ElectionExecuted(address candidate, string position);

    // Constructor
    constructor(address _MemberAddress, address _AdminAddress) {
        chairperson = msg.sender;
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


    // Función para crear una nueva propuesta (deben implementarla)
    function createProposal(string memory _description, uint256 _duration) external onlyMember {
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + _duration; /// que es esto? 
        newProposal.executed = false;
        proposalCount++;
        emit ProposalCreated(proposalCount, _description, newProposal.deadline);
    }

    // Función para votar en una propuesta (deben implementarla)
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

    // Función para ejecutar una propuesta (deben implementarla)
    function executeProposal(uint256 _proposalId) external onlyChairperson {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.deadline, "La votacion aun no ha terminado");
        require(!proposal.executed, "La propuesta ya ha sido ejecutada");

        if (proposal.votesFor > proposal.votesAgainst) {
            // Implementar la logica para ejecutar la propuesta
            proposal.executed = true;
            emit ProposalExecuted(_proposalId);
        }
    }
  // Función para iniciar una elección para presidente o tesorero
    function startElection(string memory _position, address _candidate, uint256 _duration) external onlyAdmin {
        Election storage newElection = elections[electionCount];
        newElection.position = _position;
        newElection.candidate = _candidate;
        newElection.deadline = block.timestamp + _duration;
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
            chairperson = election.candidate;
        } else if (keccak256(bytes(election.position)) == keccak256(bytes("treasurer"))) {
            treasurer = election.candidate;
        }

        emit ElectionExecuted(election.candidate, election.position);
    }

}
