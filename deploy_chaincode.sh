#!/bin/bash

# Exit on first error
set -e

# Environment Variables
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}

# Set Go environment variables
export GO111MODULE=on
export GOPROXY=https://proxy.golang.org,direct
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Variables
CHAINCODE_NAME="voting"
CHAINCODE_VERSION="1.0"
CHAINCODE_SEQUENCE="1"
CHAINCODE_PATH="chaincode"
CHANNEL_NAME="cretechannel"
ORDERER_CA="/etc/hyperledger/fabric/crypto-config/ordererOrganizations/crete.com/orderers/orderer.crete.com/msp/tlscacerts/tlsca.crete.com-cert.pem"
ORDERER_ADDRESS="orderer.crete.com:7050"

# List of peers
PEERS=("peer0.heraklion.crete.com" "peer0.chania.crete.com" "peer0.rethymno.crete.com" "peer0.lasithi.crete.com")
MSP=("HeraklionMSP" "ChaniaMSP" "RethymnoMSP" "LasithiMSP")
DOMAINS=("heraklion.crete.com" "chania.crete.com" "rethymno.crete.com" "lasithi.crete.com")

echo "🔹 Packaging Chaincode..."
docker exec cli peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CHAINCODE_PATH} --lang golang --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION}

# Install Chaincode on All Peers
for i in "${!PEERS[@]}"; do
    PEER_NAME=${PEERS[$i]}
    DOMAIN=${DOMAINS[$i]}
    MSP_ID=${MSP[$i]}

    echo "🔹 Installing Chaincode on ${PEER_NAME}..."
    docker exec -e CORE_PEER_LOCALMSPID=${MSP_ID} \
        -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp \
        -e CORE_PEER_ADDRESS=${PEER_NAME}:7051 \
        cli peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
done

# Query Installed Chaincode Package ID
echo "🔹 Querying Chaincode Package ID..."
PACKAGE_ID=$(docker exec cli peer lifecycle chaincode queryinstalled | grep "${CHAINCODE_NAME}_${CHAINCODE_VERSION}" | awk -F "Package ID: " '{print $2}' | awk -F ", Label:" '{print $1}')

if [[ -z "$PACKAGE_ID" ]]; then
    echo "❌ Error: Chaincode Package ID not found!"
    exit 1
fi
echo "✅ Package ID: ${PACKAGE_ID}"

# Approve Chaincode for All Organizations
for i in "${!PEERS[@]}"; do
    PEER_NAME=${PEERS[$i]}
    DOMAIN=${DOMAINS[$i]}
    MSP_ID=${MSP[$i]}

    echo "🔹 Approving Chaincode for ${PEER_NAME}..."
    docker exec -e CORE_PEER_LOCALMSPID=${MSP_ID} \
        -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp \
        -e CORE_PEER_ADDRESS=${PEER_NAME}:7051 \
        cli peer lifecycle chaincode approveformyorg \
        -o ${ORDERER_ADDRESS} --tls --cafile ${ORDERER_CA} \
        --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} \
        --version ${CHAINCODE_VERSION} --package-id ${PACKAGE_ID} --sequence ${CHAINCODE_SEQUENCE} --init-required
done

# Check Commit Readiness
echo "🔹 Checking Commit Readiness..."
docker exec cli peer lifecycle chaincode checkcommitreadiness \
    --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} \
    --sequence ${CHAINCODE_SEQUENCE} --output json --tls --cafile ${ORDERER_CA} --init-required

# Commit the Chaincode
echo "🔹 Committing Chaincode..."
docker exec cli peer lifecycle chaincode commit \
    -o ${ORDERER_ADDRESS} --tls --cafile ${ORDERER_CA} \
    --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} \
    --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} --init-required \
    --peerAddresses peer0.heraklion.crete.com:7051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/heraklion.crete.com/tlsca/tlsca.heraklion.crete.com-cert.pem \
    --peerAddresses peer0.chania.crete.com:8051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/chania.crete.com/tlsca/tlsca.chania.crete.com-cert.pem \
    --peerAddresses peer0.rethymno.crete.com:9051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/rethymno.crete.com/tlsca/tlsca.rethymno.crete.com-cert.pem \
    --peerAddresses peer0.lasithi.crete.com:10051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/lasithi.crete.com/tlsca/tlsca.lasithi.crete.com-cert.pem

# Query Committed Chaincode
echo "🔹 Querying Committed Chaincode..."
docker exec cli peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME}

# Initialize the Chaincode (if required)
echo "🔹 Initializing Chaincode..."
docker exec cli peer chaincode invoke \
    -o ${ORDERER_ADDRESS} --tls --cafile ${ORDERER_CA} \
    -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    --peerAddresses peer0.heraklion.crete.com:7051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/heraklion.crete.com/tlsca/tlsca.heraklion.crete.com-cert.pem \
    --peerAddresses peer0.chania.crete.com:8051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/chania.crete.com/tlsca/tlsca.chania.crete.com-cert.pem \
    --peerAddresses peer0.rethymno.crete.com:9051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/rethymno.crete.com/tlsca/tlsca.rethymno.crete.com-cert.pem \
    --peerAddresses peer0.lasithi.crete.com:10051 --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/lasithi.crete.com/tlsca/tlsca.lasithi.crete.com-cert.pem \
    -c '{"Args":["InitLedger"]}' --isInit

echo "✅ Chaincode deployment completed successfully!"
