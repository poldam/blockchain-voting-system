# blockchain-voting-system
This thesis presents the design and implementation of a Blockchain-Based Secure Voting System, leveraging the decentralized, immutable, and transparent nature of blockchain technology to ensure the integrity, security, and confidentiality of voting processes. 

## Prerequisites
- Docker version 27.4.1, build b9d17ea
- Docker Compose version v2.32.1
- go version go1.20.5 linux/amd64
- hyperledger/fabric-peer 2.5.10

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/poldam/blockchain-voting-system.git
   cd blockchain-voting-system

## Run Network
chmod +x setup-network.sh
./setup-network.sh

## Shut down the network
docker-compose down