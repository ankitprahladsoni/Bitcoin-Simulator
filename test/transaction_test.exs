defmodule TransactionTest do
  use ExUnit.Case
  doctest BlockChain
  import Common

  setup do
    Server.init()

    {:ok, peers: Common.getPeers()}
  end

  # ======================= Functional tests ===================

  test "get coinbase transaction" do
    coinbaseTx = Transaction.getCoinbaseTx("peer1", 1)
    assert coinbaseTx.txIns |> length() == 1
    assert coinbaseTx.txOuts |> length() == 1
    assert coinbaseTx.id == Transaction.createTxId(coinbaseTx)
  end

  test "No Txs in TxPool for Genesis Block" do
    assert Server.getTxPool() |> length() == 0
  end

  test "Transactions update UtxOuts and TxPool", state do
    mine(state, 0)
    assert Server.getTxPool() |> length() == 0
    # only one UTXO for full amount
    sendTransaction(state, 0, 1, 50)
    assert Server.getUTxOs() |> length() == 2

    sendTransaction(state, 1, 0, 30)
    # two txs for breaking down
    assert Server.getUTxOs() |> length() == 4
  end

  test "Correct break down of a Transaction in UtxOuts list", state do
    # coinbase transaction is 50 by default.
    mine(state, 0)
    assert Server.getTxPool() |> length() == 0
    sendTransaction(state, 0, 1, 20)
    [utxOut | rem] = Server.getUTxOs()
    assert utxOut.address == getPeer(state, 0)
    # remaining of the transaction.
    assert utxOut.amount == 50
    assert hd(rem).address == getPeer(state, 0)
    assert hd(rem).amount == 30
  end

  test "validity of a legitimate transaction", state do
    # utxo size = 1
    mine(state, 0)
    assert Server.getTxPool() |> length() == 0
    assert Server.getUTxOs() |> length() == 1

    # utxo size = 2
    sendTransaction(state, 0, 1, 20)
    # 2+1
    assert Server.getUTxOs() |> length == 3
    tx = hd(Server.getTxPool())
    uTxOs = Server.getUTxOs()
    assert TxValidator.validTx?(tx, uTxOs)
  end

  test "validity of n legitimate transactions", state do
    # initial money from mining = 50
    # utxo size = 1
    mine(state, 0)

    # Considering all the cases of sending currency
    # for leftover cases and no leftover cases
    # in both directions

    # 0 -> 1 , 2 utxos for breaking down
    sendTransaction(state, 0, 1, 40)
    # 0 -> 1 , 1 utxos for breaking down
    sendTransaction(state, 0, 1, 10)
    # 1 -> 0 , 2 utxos for breaking down
    sendTransaction(state, 1, 0, 10)
    # 1 -> 0 , 1 utxos for breaking down
    sendTransaction(state, 1, 0, 40)

    # 1+2+1+2+1
    assert Server.getUTxOs() |> length() == 7
    uTxOs = Server.getUTxOs()
    Enum.each(Server.getTxPool(), fn tx -> assert TxValidator.validTx?(tx, uTxOs) end)
  end

  test "invalid transaction", state do
    mine(state, 0)
    assert Server.getTxPool() |> length() == 0
    sendTransaction(state, 0, 1, 20)
    assert Server.getTxPool() |> length() == 1
    tx = hd(Server.getTxPool())
    txouts = hd(Server.getTxPool()).txOuts
    assert Enum.at(txouts, 0).amount == 30

    # modify txOuts of the transaction by changing the address to a malicious peer.
    txouts = [
      Enum.at(txouts, 0) |> Map.put(:address, "malicious_address"),
      Enum.at(txouts, 1) |> Map.put(:address, "malicious_address")
    ]

    manupulated_tx = %{id: tx.id, txIns: tx.txIns, txOuts: txouts}

    # original tx validation
    assert Enum.at(tx.txOuts, 0).address != "malicious_address"
    assert Enum.at(tx.txOuts, 1).address != "malicious_address"
    assert TxValidator.validTx?(tx, Server.getUTxOs())

    # modified tx validaton
    assert Enum.at(manupulated_tx.txOuts, 0).address == "malicious_address"
    assert Enum.at(manupulated_tx.txOuts, 1).address == "malicious_address"
    refute TxValidator.validTx?(manupulated_tx, Server.getUTxOs())
  end

  test "validity of a coinbase transaction" do
    coinbaseTx = Transaction.getCoinbaseTx("peer1", 1)
    assert coinbaseTx.id == Transaction.createTxId(coinbaseTx)
    assert TxValidator.validCoinbase?(coinbaseTx, 1)
  end

  test "invalidity of a modified coinbase transaction" do
    coinbaseTx = Transaction.getCoinbaseTx("peer1", 1)
    assert coinbaseTx.id == Transaction.createTxId(coinbaseTx)
    # manupulating txOuts to get more money than cbamount for mining >50
    newtxOuts = [%{address: "peer1", amount: 70}]
    newCoinBaseTx = %{id: coinbaseTx.id, txIns: coinbaseTx.txIns, txOuts: newtxOuts}
    refute TxValidator.validCoinbase?(newCoinBaseTx, 1)
  end

  # =================== Unit tests =============================

  test "getTransactionId" do
    txIns = [%{sign: "", txOutId: "1", txOutIndex: 1}]
    txOuts = [%{address: "self", amount: 50}]
    id = Transaction.createTxId(%{txIns: txIns, txOuts: txOuts})
    tx = Transaction.create(txIns, txOuts)
    assert id == tx.id
  end

  test "insAndOutAmountMatches", state do
    mine(state, 0)
    sendTransaction(state, 0, 1, 20)
    mine(state, 1)
    uTxOs = Server.getUTxOs()
    txs = Server.getTxPool()
    assert TxValidator.validAll?(txs, uTxOs)
  end

  test "processTxForBlock", state do
    mine(state, 0)
    sendTransaction(state, 0, 1, 20)
    mine(state, 1)
    uTxOs = Server.getUTxOs()
    txs = Server.getTxPool()

    modifiedUtxOs = uTxOs |> Enum.map(fn x -> Map.put(x, :amount, 100) end)

    Enum.each(txs, fn tx ->
      assert Transaction.processTransactions(tx, modifiedUtxOs) == nil
    end)
  end

  test "create transaction" do
    txIns = [%{sign: "", txOutId: "1", txOutIndex: 1}]
    txOuts = [%{address: "self", amount: 50}]
    id = Transaction.createTxId(%{txIns: txIns, txOuts: txOuts})
    tx = %{txIns: txIns, txOuts: txOuts, id: id}
    assert Transaction.create(txIns, txOuts) == tx
  end

  test "TxIn stringify" do
    txIns = [%{sign: "", txOutId: "1", txOutIndex: 1}]
    assert TxIn.stringify(txIns) == "11"
  end

  test "TxOut stringify" do
    txOuts = [%{address: "self", amount: 50}]
    assert TxOut.stringify(txOuts) == "self50"
  end

  test "insAndOutsToStr" do
    txIns = [%{sign: "", txOutId: "1", txOutIndex: 1}]
    txOuts = [%{address: "self", amount: 50}]

    string =
      Transaction.create(txIns, txOuts)
      |> Transaction.insAndOutsToStr()

    assert string == "11self50"
  end

  test "updating a block to chain with invalid transactions" do
    mineFromStaticAddress("0")
    mineFromStaticAddress("1")

    cb =
      Transaction.getCoinbaseTx("1", 2)
      |> Map.put(:txOuts, [%{address: "self", amount: 50}, %{address: "friend", amount: 1000}])

    newTxId = Transaction.createTxId(cb)
    cb = Map.put(cb, :id, newTxId)

    block =
      Server.getLastestBlock()
      |> Map.put(:blockData, [Transaction.getCoinbaseTx("1", 2), cb])
      |> Map.put(:prvHash, Server.getLastestBlock().hash)
      |> Map.put(:index, 2)
      |> BlockChain.updateWithHash()


      refute Transaction.processTransactions(Enum.at(block.blockData, 0), Server.getUTxOs()) != nil

    assert_raise RuntimeError, fn -> Server.updateChain(block) end
  end
end
