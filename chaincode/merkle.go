package main

import (
	"crypto/sha256"
	"encoding/hex"
)

// MerkleNode represents a node in a Merkle Tree
type MerkleNode struct {
	Left  *MerkleNode
	Right *MerkleNode
	Hash  string
}

// CreateMerkleTree generates a Merkle Tree from vote hashes
func CreateMerkleTree(voteHashes []string) *MerkleNode {
	if len(voteHashes) == 0 {
		return nil
	}

	nodes := make([]*MerkleNode, len(voteHashes))
	for i, hash := range voteHashes {
		nodes[i] = &MerkleNode{Hash: hash}
	}

	for len(nodes) > 1 {
		var newLevel []*MerkleNode

		for i := 0; i < len(nodes); i += 2 {
			if i+1 < len(nodes) {
				combinedHash := sha256.Sum256([]byte(nodes[i].Hash + nodes[i+1].Hash))
				newNode := &MerkleNode{Left: nodes[i], Right: nodes[i+1], Hash: hex.EncodeToString(combinedHash[:])}
				newLevel = append(newLevel, newNode)
			} else {
				newLevel = append(newLevel, nodes[i])
			}
		}
		nodes = newLevel
	}

	return nodes[0]
}

// GenerateMerkleRoot computes the Merkle Root from vote data
func GenerateMerkleRoot(voteHashes []string) string {
	merkleTree := CreateMerkleTree(voteHashes)
	if merkleTree != nil {
		return merkleTree.Hash
	}
	return ""
}

// VerifyMerkleRoot ensures the computed Merkle Root matches stored records
func VerifyMerkleRoot(expectedRoot string, voteHashes []string) bool {
	computedRoot := GenerateMerkleRoot(voteHashes)
	return computedRoot == expectedRoot
}
