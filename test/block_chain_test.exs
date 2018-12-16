defmodule BlockChainTest do
  use ExUnit.Case
  doctest BlockChain

  import Common

  setup do
    Server.init()

    {:ok, peers: Common.getPeers()}
  end

  # ================ Functional tests ==================

  test "get all for the first time" do
    assert Server.getChain() == []
  end

  test "validity of a block", state do
    mine(state, 0)
    sendTransaction(state, 0, 1, 10)
    mine(state, 0)

    # create a transaction but dont mine for it to present in the TxPool
    sendTransaction(state, 0, 1, 10)

    block =
      Transaction.createTxForBlock("address", Server.getChain() |> length)
      |> BlockChain.createBlock(Server.getChain())
      |> BlockChain.updateWithHash()

    assert BlockChainValidator.validBlock?(block)
  end

  test "updatechain for tampered Transaction", state do
    mine(state, 0)
    sendTransaction(state, 0, 1, 10)
    mine(state, 0)
    # create a transaction but dont mine for it to present in the TxPool
    sendTransaction(state, 0, 1, 10)
    # run the mine logic. UpdateChain finishes the mine and updates the blockchain.
    block =
      Transaction.createTxForBlock("address", Server.getChain() |> length)
      |> BlockChain.createBlock(Server.getChain())
      |> BlockChain.updateWithHash()

    block = Map.put(block, :hash, "wrong hash")
    # Should not update chain
    assert_raise RuntimeError, fn -> Server.updateChain(block) end
  end

  test "invalidity of a modified block", state do
    mine(state, 0)
    sendTransaction(state, 0, 1, 10)
    mine(state, 0)

    # create a transaction but dont mine for it to present in the TxPool
    sendTransaction(state, 0, 1, 10)

    block =
      Transaction.createTxForBlock("address", Server.getChain() |> length)
      |> BlockChain.createBlock(Server.getChain())
      |> BlockChain.updateWithHash()

    # Modify the nonce of the block. Simulating the case where
    # the miner is bluffing and hasn't solved the
    # difficulty problem.
    block = Map.put(block, :nonce, -1)
    refute BlockChainValidator.validBlock?(block)
  end

  test "n number of transactions create only one additional block on mining", state do
    mine(state, 0)
    assert Server.getChain() |> length() == 1

    Enum.each(1..50, fn _x -> sendTransaction(state, 0, 1, 1) end)

    mine(state, 1)
    assert Server.getChain() |> length() == 2
    assert getBalance(state, 1) == 100
    assert getBalance(state, 0) == 0
  end

  # ================= unit test ========================
  # test dependent on the address of the peer -> 0
  test "mined block structure" do
    block_structure = [
      %{
        blockData: [
          %{
            id: "D5F0C33021595F4DB1659F924EDC67658A477AABBABCBB7CC8EAA647CACC329B",
            txIns: [%{sign: "", txOutId: "", txOutIndex: 0}],
            txOuts: [%{address: "0", amount: 50}]
          }
        ],
        hash: "000751F463D5F088152BB55ECFB010F95036B517728A8C30E9057B7326F32026",
        index: 0,
        nonce: 12257,
        prvHash: ""
      }
    ]

    mineFromStaticAddress("0")
    actual = Server.getChain()
    assert actual == block_structure
  end

  test "block size monotonically increases", state do
    mine(state, 0)
    assert Server.getChain() |> length() == 1

    mine(state, 1)
    assert Server.getChain() |> length() == 2
  end

  test "check previous hash", state do
    mine(state, 0)
    mine(state, 1)

    assert Server.getChain() |> length() == 2
    [latest | remaining] = Server.getChain()

    previous = hd(remaining)

    assert previous.prvHash == ""
    assert latest.prvHash == previous.hash
  end

  test "validWithPrevious? function", state do
    mine(state, 0)
    sendTransaction(state, 0, 1, 10)
    mine(state, 1)
    prevTx = Server.getLastestBlock()
    sendTransaction(state, 0, 1, 10)
    mine(state, 1)
    currentTx = Server.getLastestBlock()
    assert Server.getChain() |> length() == 3
    assert BlockChainValidator.validWithPrevious?(currentTx, prevTx)
  end

  test "validWithPrevious? function with coinbase tx", state do
    mine(state, 0)
    prevTx = Server.getLastestBlock()
    sendTransaction(state, 0, 1, 10)
    mine(state, 0)
    currentTx = Server.getLastestBlock()
    assert BlockChainValidator.validWithPrevious?(currentTx, prevTx)
  end
end
