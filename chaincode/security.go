package main

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"errors"
)

// EncryptData encrypts input data using AES
func EncryptData(data string, key string) (string, error) {
	block, err := aes.NewCipher([]byte(key))
	if err != nil {
		return "", err
	}

	nonce := make([]byte, 12) // AES-GCM requires a 12-byte nonce
	ciphertext := make([]byte, len(data))

	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	encrypted := aesGCM.Seal(nil, nonce, []byte(data), nil)
	return base64.StdEncoding.EncodeToString(encrypted), nil
}

// DecryptData decrypts AES encrypted data
func DecryptData(encryptedData string, key string) (string, error) {
	encryptedBytes, err := base64.StdEncoding.DecodeString(encryptedData)
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher([]byte(key))
	if err != nil {
		return "", err
	}

	nonce := make([]byte, 12)
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	decrypted, err := aesGCM.Open(nil, nonce, encryptedBytes, nil)
	if err != nil {
		return "", errors.New("decryption failed")
	}

	return string(decrypted), nil
}
