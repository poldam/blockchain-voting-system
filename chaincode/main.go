package main

import (
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	votingChaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		panic("Error creating chaincode: " + err.Error())
	}

	if err := votingChaincode.Start(); err != nil {
		panic("Error starting chaincode: " + err.Error())
	}
}
