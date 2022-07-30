const Web3 = require('web3');

const Tx = require('ethereumjs-tx').Transaction;
const solc = require('solc');
const fs = require('fs');
require('dotenv').config();

const API_URL = process.env.PROVIDER;
const PUBLIC_KEY = process.env.ADDRESS1;
const PRIVATE_KEY = process.env.ADDRESS1_KEY;
const network = process.env.ETHEREUM_NETWORK;

var web3 = new Web3(new Web3.providers.HttpProvider(API_URL));
//console.log(web3.eth.Contract);
const express = require('express');
const router = express.Router();

const contract = require('../routes/contractFrac');
const WeCoinRes4 = new web3.eth.Contract(contract.contractABI, contract.contractAddress);

const contractFWCT = require('../routes/contractFracFWCT');
const WeCoinFWCT = new web3.eth.Contract(contractFWCT.contractABI, contractFWCT.contractAddress);

const contractRF = require('../routes/contractRecFrac');
const WeCoinRC = new web3.eth.Contract(contractRF.contractABI, contractRF.contractAddress);

const contractAddress = contractRF.contractAddress;
const contractAbi = contractRF.contractABI;
const contractCode = contractRF.contractCode;
const contractCodeObj = contractRF.contractCodeObj;

async function activos(dirFrac, activoId) {
    const reasset = [];
  // Creating a signing account from a private key
    const signer = web3.eth.accounts.privateKeyToAccount(
      process.env.ADDRESS1_KEY
    );
    web3.eth.accounts.wallet.add(signer);

    const reclamo = new web3.eth.Contract(contractAbi);
    reclamo.options.data = contractCodeObj;
    //.deploy({data: contractCodeObj, arguments: [ dirFrac, activoId ]})
    //console.log(reclamo)

    //reclamo.options.data = contractCodeObj;
    //reclamo.options.arguments = [ dirFrac, activoId ];
    //data: contractCode,
    const deployTx = reclamo.deploy({
      arguments: [ dirFrac, activoId ]
    });
    //console.log(deployTx);
    //const estimategas = await deployTx.estimateGas();
    //console.log(estimategas);

    const deployedContract = await deployTx
      .send({
        from: PUBLIC_KEY,
        gas: 6700000,
        gasPrice: 10000000000,
      })
      .once("transactionHash", (txhash) => {
        console.log(`Mining deployment transaction ...`);
        console.log(`https://${network}.etherscan.io/tx/${txhash}`);
    });

    // The contract is now deployed on chain!
    console.log(`Contract deployed at ${deployedContract.options.address}`);
    console.log(`Add DEMO_CONTRACT to the.env file to store the contract address: ${deployedContract.options.address}`);
    reasset.push({
      DirFrac: dirFrac,
      Id: activoId,
      from: PUBLIC_KEY,
      deployedContractAddress: deployedContract.options.address,
      deployedContract: deployedContract
  });
  console.log(reasset)
  return await JSON.stringify(reasset);

}
module.exports.activos = activos