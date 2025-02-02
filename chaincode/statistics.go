package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// UpdateStatistics updates aggregated vote statistics
func (s *SmartContract) UpdateStatistics(ctx contractapi.TransactionContextInterface, candidateID string, partyID string, region string, age string, gender string, timestamp string) error {
	statKey := fmt.Sprintf("stats_%s_%s", candidateID, region)

	statData, err := ctx.GetStub().GetState(statKey)
	if err != nil {
		return fmt.Errorf("failed to retrieve statistics: %v", err)
	}

	var voteStat VoteStatistics
	if statData != nil {
		err = json.Unmarshal(statData, &voteStat)
		if err != nil {
			return fmt.Errorf("error decoding statistics data: %v", err)
		}
	} else {
		voteStat = VoteStatistics{
			CandidateID: candidateID,
			PartyID:     partyID,
			Region:      region,
			Age:         age,
			Gender:      gender,
			Timestamp:   timestamp,
		}
	}

	updatedStatJSON, err := json.Marshal(voteStat)
	if err != nil {
		return fmt.Errorf("error encoding statistics data: %v", err)
	}

	return ctx.GetStub().PutState(statKey, updatedStatJSON)
}

// GetStatistics retrieves aggregated vote statistics
func (s *SmartContract) GetStatistics(ctx contractapi.TransactionContextInterface, candidateID string, region string) (*VoteStatistics, error) {
	statKey := fmt.Sprintf("stats_%s_%s", candidateID, region)
	statData, err := ctx.GetStub().GetState(statKey)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve statistics: %v", err)
	}

	if statData == nil {
		return nil, fmt.Errorf("no statistics found for candidate %s in region %s", candidateID, region)
	}

	var voteStat VoteStatistics
	err = json.Unmarshal(statData, &voteStat)
	if err != nil {
		return nil, fmt.Errorf("error decoding statistics data: %v", err)
	}

	return &voteStat, nil
}
