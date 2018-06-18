#!/bin/bash
echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build multi host network (BMHN) end-to-end test"
echo
CHANNEL_NAME="$1"
DELAY="$2"
: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo "Channel name : "$CHANNEL_NAME

# verify the result of the end-to-end test
verifyResult () {
        if [ $1 -ne 0 ] ; then
                echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
                echo
                exit 1
        fi
}

setGlobals () {
        CORE_PEER_LOCALMSPID="Org1MSP"
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        CORE_PEER_ADDRESS=peer$1.org1.example.com:7051
        env |grep CORE
}


## Sometimes Join takes time hence RETRY atleast for 5 times
joinWithRetry () {
        peer channel join -b genesis_block.pb  >&log.txt
        res=$?
        cat log.txt
        if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
                COUNTER=` expr $COUNTER + 1`
                echo "PEER$1 failed to join the channel, Retry after 2 seconds"
                sleep $DELAY
                joinWithRetry $1
        else
                COUNTER=1
        fi
  verifyResult $res "After $MAX_RETRY attempts, PEER$ch has failed to Join the Channel"
}

joinChannel () {
        setGlobals $1
        ch=5
        joinWithRetry $ch
        echo "===================== PEER$ch joined on the channel \"$CHANNEL_NAME\" ==$
        sleep $DELAY
        echo
        
}
installChaincode () {
        PEER=$1
        setGlobals $PEER
        peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincoode/go/chaincode_example02 >&log.txt
        res=$?
        cat log.txt
        verifyResult $res "Chaincode installation on remote peer PEER$PEER has Failed"
        echo "===================== Chaincode is installed on remote peer PEER$PEER ==========$
        echo
}

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel $1

echo "Install chaincode on org1/peer2..."
installChaincode $1














