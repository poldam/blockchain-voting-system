package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// RegisterVoter registers a new voter
func (s *SmartContract) RegisterVoter(ctx contractapi.TransactionContextInterface, voterID string, name string, region string, birthdate string, gender string, eligible bool) error {
	exists, err := s.VoterExists(ctx, voterID)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("voter with ID %s already exists", voterID)
	}

	voter := Voter{
		ID:       voterID,
		Name:     name,
		Region:   region,
		Birthdate: birthdate,
		Gender:   gender,
		Eligible: eligible,
		HasVoted: false,
	}

	voterJSON, err := json.Marshal(voter)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(voterID, voterJSON)
}

// VoterExists checks if a voter exists
func (s *SmartContract) VoterExists(ctx contractapi.TransactionContextInterface, voterID string) (bool, error) {
	voterJSON, err := ctx.GetStub().GetState(voterID)
	if err != nil {
		return false, fmt.Errorf("failed to read from ledger: %v", err)
	}
	return voterJSON != nil, nil
}
