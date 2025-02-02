package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SubmitVote records a new vote
func (s *SmartContract) SubmitVote(ctx contractapi.TransactionContextInterface, voterID string, candidateID string, partyID string, region string, age string, gender string, timestamp string) error {
	encryptedVote := EncryptedVote{
		VoterID:     voterID,
		CandidateID: candidateID,
		PartyID:     partyID,
		Region:      region,
		Age:         age,
		Gender:      gender,
		Timestamp:   timestamp,
	}

	voteJSON, err := json.Marshal(encryptedVote)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(voterID+"_vote", voteJSON)
}
