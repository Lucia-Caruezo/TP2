# Trabajo Práctico Número 2: Desarrollo de una DAO
Trabajo Práctico Número 2 de la materia Introducción a Blockchain, dictada durante el primer semestre de 2024 (Escuela de Negocios, Universidad Torcuato Di Tella), realizado por Lucia Caruezo, 

## Introducción
Este repositorio contiene un template de implementación de una Organización Autónoma Descentralizada (DAO). Incluye el código base de los contratos inteligentes, scripts de deploy y pruebas.

### Desarrollo y Deployment

Los contratos fueron desarrollados en Remix y deployados en la testnet de Sepolia. 

### Contratos

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
