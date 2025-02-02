START API: 
node api/server.js

CREATE NETWORK: 
./setup-network.sh

CHECK THAT DOCKERS ARE UP AND RUNNING: 
docker ps

install, approve, and commit your chaincode
cd chaincode
go mode init chaincode
go mod tidy

./deploy_chaincode.sh

