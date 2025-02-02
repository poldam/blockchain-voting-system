package main

// Candidate structure
type Candidate struct {
	PartyID     string `json:"partyID"`
	PartyName   string `json:"partyName"`
	Name        string `json:"name"`
	CandidateID string `json:"candidateID"`
	SupportedBy string `json:"supportedBy"`
}

// Voter structure
type Voter struct {
	ID                string `json:"id"`
	Name              string `json:"name"`
	Region            string `json:"region"`
	Birthdate         string `json:"birthdate"`
	Gender            string `json:"gender"`
	Eligible          bool   `json:"eligible"`
	HasVoted          bool   `json:"has_voted"`
	VotingInProgress  bool   `json:"voting_in_progress"`
}

// Encrypted Vote structure
type EncryptedVote struct {
	VoterID     string `json:"voterID"`
	CandidateID string `json:"candidateID"`
	PartyID     string `json:"partyID"`
	Region      string `json:"region"`
	Age         string `json:"age"`
	Gender      string `json:"gender"`
	Timestamp   string `json:"timestamp"`
}

// Vote statistics structure
type VoteStatistics struct {
	CandidateID string `json:"candidateID"`
	PartyID     string `json:"partyID"`
	Region      string `json:"region"`
	Age         string `json:"age"`
	Gender      string `json:"gender"`
	Timestamp   string `json:"timestamp"`
}
