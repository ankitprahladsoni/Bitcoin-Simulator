defmodule Server do
  import UTxO

  def init() do
    :ets.new(:tbl, [:set, :public, :named_table])
    :ets.insert(:tbl, {:bc, []})
    :ets.insert(:tbl, {:txPool, []})
    :ets.insert(:tbl, {:utxo, []})
  end

  def updateChain(block) do
    if BlockChainValidator.validBlock?(block) do
      newUTxOs = Transaction.processTxForBlock(block.blockData, getUTxOs())

      if newUTxOs == nil do
        raise "block doesn't have valid transactions"
      else
        updateBChain(block)
        updateUTxOs(newUTxOs)

        updateTransactionPool(newUTxOs)
      end
    else
      raise "Block is invalid"
    end
  end

  def updateTransactionPool(uTxOs) do
    getTxPool()
    |> Enum.filter(fn tx -> !notInUTxOs(tx, uTxOs) end)
    |> updateTxPool()
  end

  def addToTransactionPool(tx) do
    if TxValidator.validTx?(tx, getUTxOs()) do
      updateTxPool(getTxPool() ++ [tx])
    end
  end

  def getUTxOs(), do: getFromTable(:utxo)

  def updateUTxOs(uTxOs), do: :ets.insert(:tbl, {:utxo, uTxOs})

  def getTxPool(), do: getFromTable(:txPool)

  defp updateTxPool(txPool), do: :ets.insert(:tbl, {:txPool, txPool})

  def getChain(), do: getFromTable(:bc)

  defp updateBChain(block), do: :ets.insert(:tbl, {:bc, [block | getChain()]})

  def getLastestBlock() do
    case :ets.lookup(:tbl, :bc) do
      [{_, [head | _tail]}] -> head
      [{_, []}] -> nil
    end
  end

  defp getFromTable(key) do
    case :ets.lookup(:tbl, key) do
      [{_, value}] -> value
      [] -> []
    end
  end
end
