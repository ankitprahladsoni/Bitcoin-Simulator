ExUnit.start()

defmodule Common do
  def getPeers() do
    Enum.map(0..1, fn _x -> HashUtil.createPair() end)
  end

  def getPeer(state, index) do
    {public, _private} = getPeerTuple(state, index)
    public
  end

  defp getPeerTuple(state, index) do
    state.peers |> Enum.at(index)
  end

  def mine(state, index) do
    getPeer(state, index) |> BlockChain.mine()
  end

  def mineFromStaticAddress(publicAddress) do
    BlockChain.mine(publicAddress)
  end

  def getBalance(state, index) do
    getPeer(state, index) |> Wallet.balance()
  end

  def sendTransaction(state, from, to, amount) do
    fromAddr = getPeerTuple(state, from)
    toAddr = getPeer(state, to)
    Wallet.sendTransaction(fromAddr, toAddr, amount)
  end
end
