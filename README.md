# Proj4a Bitcoin Protocols - Test driven Approach
## Contributors:
* [Ankit Soni- 8761-9158](http://github.com/ankitprahladsoni)
* [Kumar Kunal- 5100-5964](http://github.com/kunal4892)

# Description


The project covers the implementation of all the Bitcoin protocols that
are necessary to mine, send and keep a balance. The features are discussed in details below:

*1. Mine bitcoins and earn money(coinbase transaction) by validating n previous transactions (solving a difficult hash matching problem):*
   We define block and blockchain structure and provide methods to add new blocks to the blockchain with data. Proof of work, Difficulty, nonce is implemented(difficult to solve, but easy to verify). Difficulty is kept to 3 zeroes "000" as a prefix in the calcluated hash. Consensus of difficulty is implemented.It can be changed (increased/decreased) at regular intervals based on the time current miners are taking to solve the present difficulty problem. Underlying datastructures like the transactionPool that collect transactions are updated(reset). Mining accomplishes certifying that the transactions are legitimate.

*2. Send bitcoins as transactions to other peers (public addresses):*
   Underlying datastructures for Transactions(id, TxIns[] and TxOuts), Blockchain, TransactionPool 
   are implemented to make transactions between peers possible.
   Underlying datastructure transactionPool that colelcts transactions is added with a new entry of the current transaction.
   When a peer sends some currency to others, it refers to another datastructure called as UnspentTransactionOuts(covered more in wallet), to find out the exact amount the user has. This amount can be transferred. The transfer works by breaking the n UnspentTransactionOuts Into TransactionIns[] and TransactionOuts[]. TransactionOuts[] bind the currency to the recieving peer's address and the remaining change amount with it's own addres. TransactionIns[] contain the data that supplement verification by any party/server that needs to verify whether the transaction is legitimate and not malicious.

*3. Maintain wallets for all Peers in the network by using private-public key encryption schemes:*
   Using Public-key cryptography and signing and verifying signatures is implemented.
   Creating a new wallet is possible. Viewing the balance of his wallet and Sending coins to other addresses is also possible.
   UnspentTransactionsOuts datastructure is implemented to find out the given balance of a peer's wallet
   at any given point in time by quering and filtering  all UnspentTxouts by it own public address.
   Wallets need to store the encrypted keys in the file system, but file lookups makes this a slow process.
   It is possible to look at the public keys and find out the net balance of any peer with a certain public key. Ofcourse the privacy is not compromised as these addresses don't reveal identity.

*4. Transaction Validation is covered in a very detailed manner:*
   For each transaction to be added to the pool of transactions, we make sure that the transactions added to the pool are in conformance and that no malicious transaction was slipped in the list of transaction.
   The pool of transactions are taken and clubbed together as blockData of a Block for the probable next block that will be mined and added to the Blockchain.
   Coinbase transactions or sending money to oneself and mining is implemented and also covered in the testing. Please refer to the test cases for more information as there are numerous cases to consider and each of them are handled and tested.

*5. Block and BlockChain Validation:*
   Before the Blockchain is updated, a block's own id and it's BlockData(Transactions) need to be verified.
   The information that the problem was solved by a miner(hash and monce) is stored in the prospective block. This information is verified by all peers/ the server before adding the block to their own chain. Similarly the entire chain can also be verified one block at a time, and the fact that each block maintains the hash of the previous block makes it impossible for the blocks to be modified.
   With this implementation, replacing the entire blockchain by a malicious peer is also averted, since each peer keeps maintains a local blockchain in it's own state.

*6. Broadcasting the message with updation of Blockchain.*
   As the project guidelines focus more on implementation of the protocols to make mining possible, it's understood that the distribution should be implemented in the next upgrade of the project(as also mentioned in the project requirements).

*6. Test cases and environment:*
   The test cases cover 100 percent of the lines in the code. The code coverage details are present in the report below. To mimic the real life scenario, each test case maintains a fresh new state to make sure all peers have fresh private and public key for each test case. This forces the nature of the tests cases to be purely dynamic.



# Datastructures used

```    
block_structure = [
      %{
        blockData: [
          %{
            id: "transactionId",
            txIns: [%{sign: "signedToken", txOutId: "", txOutIndex: 0}],
            txOuts: [%{address: "pubicAddress of the reciever", amount: amount}]
          }
        ],
        hash: hash,
        index: 0,
        nonce: nonce,
        prvHash: previousHash
      }
    ]
```


``` 
TxIns = [
  %{
    sign: sign, 
    txOutId: txOutId, 
    txOutIndex: txOutIndex 
  }
]
```

``` 
TxOuts = [
  %{
    address: address, 
    amount: amount
  }
]
```

```
Transactions = [
  %{
    id: "Transaction_Id"
    TxIns: []
    TxOuts: []
  }  
]
```

```
UnspentTransactionOuts = [
  %{
    txOutId: id, 
    txOutIndex: index, 
    address: address, 
    amount: amount
  }
]
```

# Running tests.

It is advisable that you compile the tests for all dependencies to be installed.

```
iex>mix compile

```

Running the test command runs all the tests in the project and gives the output statistics

```
iex>mix test

```

# Generating the test coverage report.

To generate the coverage report use:

```
iex>mix coveralls.html

```
The results can be viewed in the terminal or in the project folder under the
folder named cover in the project directory.

Example:

```
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/HashUtil.ex                                15        5        0
100.0% lib/Server.ex                                  65       26        0
100.0% lib/TxIn.ex                                    23        8        0
100.0% lib/TxOut.ex                                   21        6        0
100.0% lib/UTxO.ex                                    40       13        0
100.0% lib/block_chain.ex                             34       14        0
100.0% lib/block_chain_validator.ex                   14        6        0
  0.0% lib/proj4a.ex                                  18        0        0
100.0% lib/transaction.ex                             71       20        0
100.0% lib/tx_validator.ex                            19        6        0
100.0% lib/utils.ex                                   26        1        0
100.0% lib/wallet.ex                                  54       17        0
[TOTAL] 100.0%
----------------


```
