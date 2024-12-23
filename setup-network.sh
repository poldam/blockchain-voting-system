#!/bin/bash

# Exit on first error
set -e

# Variables
CHANNEL_NAME="cretechannel"
CONFIG_PATH="./channel-artifacts"
ORDERER_CA="./crypto-config/ordererOrganizations/crete.com/orderers/orderer.crete.com/msp/tlscacerts/tlsca.crete.com-cert.pem"
ORDERER_ADDRESS="orderer.crete.com:7050"

rm -rf ./crypto-config/
rm -rf ./channel-artifacts/

# Step 1: Generate Crypto Materials
echo "Generating crypto materials..."
cryptogen generate --config=./crypto-config.yaml --output=./crypto-config

cp crypto-config/peerOrganizations/heraklion.crete.com/users/Admin@heraklion.crete.com/msp/signcerts/Admin@heraklion.crete.com-cert.pem  crypto-config/peerOrganizations/heraklion.crete.com/msp/admincerts/
cp crypto-config/peerOrganizations/chania.crete.com/users/Admin@chania.crete.com/msp/signcerts/Admin@chania.crete.com-cert.pem crypto-config/peerOrganizations/chania.crete.com/msp/admincerts/
cp crypto-config/peerOrganizations/rethymno.crete.com/users/Admin@rethymno.crete.com/msp/signcerts/Admin@rethymno.crete.com-cert.pem crypto-config/peerOrganizations/rethymno.crete.com/msp/admincerts/
cp crypto-config/peerOrganizations/lasithi.crete.com/users/Admin@lasithi.crete.com/msp/signcerts/Admin@lasithi.crete.com-cert.pem crypto-config/peerOrganizations/lasithi.crete.com/msp/admincerts/
cp crypto-config/ordererOrganizations/crete.com/users/Admin@crete.com/msp/signcerts/Admin@crete.com-cert.pem crypto-config/ordererOrganizations/crete.com/msp/admincerts/

# Step 2: Generate Genesis Block
echo "Generating genesis block..."
configtxgen -profile CreteGenesis -channelID system-channel -outputBlock $CONFIG_PATH/genesis.block -configPath .

# Step 3: Generate Channel Configuration Transaction
echo "Generating channel configuration transaction..."
configtxgen -profile CreteChannel -outputCreateChannelTx $CONFIG_PATH/channel.tx -channelID $CHANNEL_NAME -configPath .

# Set proper permissions
echo "Adjusting permissions for the current user..."
sudo chmod -R 755 ./crypto-config ./channel-artifacts

# Step 4: Create and Join the Channel

echo "Creating Docker network..."
docker-compose down
docker network rm crete-network
docker network create --driver bridge --attachable crete-network

echo "Starting Docker containers..."
docker-compose up -d

# echo "Creating Docker network if it does not exist..."
# docker network inspect crete-network >/dev/null 2>&1 || docker network create --driver bridge --attachable crete-network

echo "Waiting for Docker containers to start..."
sleep 3

## Attached peers to network
docker network connect crete-network orderer.crete.com
docker network connect crete-network peer0.heraklion.crete.com
docker network connect crete-network peer0.chania.crete.com
docker network connect crete-network peer0.rethymno.crete.com
docker network connect crete-network peer0.lasithi.crete.com
docker network connect crete-network cli

## CHECK IF peers can be pinged:
# docker exec -it cli ping orderer.crete.com
# docker exec -it cli ping peer0.heraklion.crete.com
# docker exec -it cli ping peer0.chania.crete.com
# docker exec -it cli ping peer0.rethymno.crete.com
# docker exec -it cli ping peer0.lasithi.crete.com

# Create the channel
echo "Creating the channel..."
docker exec -e CORE_PEER_LOCALMSPID=OrdererMSP \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/ordererOrganizations/crete.com/orderers/orderer.crete.com/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/ordererOrganizations/crete.com/users/Admin@crete.com/msp \
  cli peer channel create \
  -o orderer.crete.com:7050 \
  -c cretechannel \
  -f /etc/hyperledger/fabric/channel-artifacts/channel.tx \
  --outputBlock /etc/hyperledger/fabric/channel-artifacts/cretechannel.block \
  --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/crete.com/tlsca/tlsca.crete.com-cert.pem

 
# Function to join peers to the channel
join_channel() {
  PEER_NAME=$1
  PEER_PORT=$2
  MSP=$3
  DOMAIN=$4

  echo "Joining $PEER_NAME to the channel..."
  docker exec -e CORE_PEER_LOCALMSPID=$MSP \
    -e CORE_PEER_ADDRESS=$PEER_NAME.$DOMAIN:$PEER_PORT \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/crypto-config/peerOrganizations/$DOMAIN/tlsca/tlsca.$DOMAIN-cert.pem \
    -e CORE_PEER_MSPCONFIGPATH=/crypto-config/peerOrganizations/$DOMAIN/users/Admin@$DOMAIN/msp \
    cli peer channel join \
    -b /channel-artifacts/cretechannel.block
}

# Join all peers to the channel
join_channel "peer0" 7051 "HeraklionMSP" "heraklion.crete.com"
join_channel "peer0" 8051 "ChaniaMSP" "chania.crete.com"
join_channel "peer0" 9051 "RethymnoMSP" "rethymno.crete.com"
join_channel "peer0" 10051 "LasithiMSP" "lasithi.crete.com"

# Verify channel membership
echo "Verifying channel membership..."
docker exec cli peer channel list
