require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const ccpPath = path.resolve(__dirname, '..', 'fabric-network', 'connection.json');

async function getContract() {
    const walletPath = path.join(__dirname, 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const gateway = new Gateway();
    await gateway.connect(ccpPath, { wallet, identity: 'admin', discovery: { enabled: true, asLocalhost: true } });

    const network = await gateway.getNetwork('votingchannel');
    return network.getContract('voting');
}

// Submit vote
app.post('/vote', async (req, res) => {
    try {
        const contract = await getContract();
        const { voterID, candidateID, partyID, region, age, gender, timestamp } = req.body;
        const vote = JSON.stringify({ voterID, candidateID, partyID, region, age, gender, timestamp });

        await contract.submitTransaction('SubmitVote', vote);
        res.json({ message: 'Vote submitted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Retrieve statistics
app.get('/statistics/:candidateID/:region', async (req, res) => {
    try {
        const contract = await getContract();
        const { candidateID, region } = req.params;

        const result = await contract.evaluateTransaction('GetStatistics', candidateID, region);
        res.json(JSON.parse(result.toString()));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => {
    console.log('API server running on port 3000');
});
