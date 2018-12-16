defmodule WalletTest do
  use ExUnit.Case
  doctest Wallet
  import Common

  setup do
    Server.init()

    {:ok, peers: Common.getPeers()}
  end

  # ============= Functional Tests ================
  test "mining gets money in wallet", state do
    assert getBalance(state, 0) == 0
    mine(state, 0)
    assert getBalance(state, 0) == 50
  end

  test "send money", state do
    mine(state, 0)
    assert getBalance(state, 0) == 50

    sendTransaction(state, 0, 1, 20)
    sendTransaction(state, 0, 1, 10)
    assert getBalance(state, 0) == 20
    assert getBalance(state, 1) == 30

    mine(state, 1)

    assert getBalance(state, 1) == 80
    sendTransaction(state, 0, 1, 20)
    assert getBalance(state, 0) == 0
  end

  test "send money more than in available in wallet", state do
    mine(state, 0)
    assert getBalance(state, 0) == 50

    assert_raise RuntimeError, fn -> sendTransaction(state, 0, 1, 100) end
    assert getBalance(state, 0) == 50
    assert getBalance(state, 1) == 0
  end

  # ================= Unit Tests ===================
end
