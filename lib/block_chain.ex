defmodule BlockChain do
  import HashUtil

  def mine(address) do
    blocks = Server.getChain()
    index = length(blocks)
    txs = Transaction.createTxForBlock(address, index)

    createBlock(txs, blocks) |> updateWithHash() |> Server.updateChain()
  end

  def createBlock(blockData, []), do: %{index: 0, prvHash: "", blockData: blockData}

  def createBlock(blockData, [latest | _remaining]),
    do: %{index: latest.index + 1, prvHash: latest.hash, blockData: blockData}

  def updateWithHash(block, nonce \\ 0) do
    hash = blockHash(block, nonce)

    cond do
      isValidHash?(hash) -> putHashNonceToBlock(block, hash, nonce)
      true -> updateWithHash(block, nonce + 1)
    end
  end

  defp putHashNonceToBlock(block, hash, nonce),
    do: Map.put(block, :hash, hash) |> Map.put(:nonce, nonce)

  def blockHash(block, nonce),
    do:
      (to_string(block.index) <>
         block.prvHash <> Transaction.stringify(block.blockData) <> to_string(nonce))
      |> hash()
end
