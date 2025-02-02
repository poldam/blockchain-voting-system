package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// AddCandidate stores a new candidate in the ledger
func (s *SmartContract) AddCandidate(ctx contractapi.TransactionContextInterface, candidateID string, partyID string, partyName string, name string, supportedBy string) error {
	exists, err := s.CandidateExists(ctx, candidateID)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("candidate with ID %s already exists", candidateID)
	}

	candidate := Candidate{
		CandidateID: candidateID,
		PartyID:     partyID,
		PartyName:   partyName,
		Name:        name,
		SupportedBy: supportedBy,
	}

	candidateJSON, err := json.Marshal(candidate)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(candidateID, candidateJSON)
}

// CandidateExists checks if a candidate exists in the ledger
func (s *SmartContract) CandidateExists(ctx contractapi.TransactionContextInterface, candidateID string) (bool, error) {
	candidateJSON, err := ctx.GetStub().GetState(candidateID)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return candidateJSON != nil, nil
}
