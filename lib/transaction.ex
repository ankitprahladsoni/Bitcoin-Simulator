defmodule Transaction do
  @cbamt 50
  import TxValidator

  def getCoinbaseTx(address, index) do
    txIn = TxIn.create("", "", index)
    txOut = TxOut.create(address, @cbamt)

    create([txIn], [txOut])
  end

  def create(txIns, txOuts) do
    tx = %{txIns: txIns, txOuts: txOuts}
    id = createTxId(tx)

    Map.put(tx, :id, id)
  end

  def createTxId(tx), do: insAndOutsToStr(tx) |> HashUtil.hash()

  def createTxForBlock(address, index), do: [getCoinbaseTx(address, index) | Server.getTxPool()]

  def stringify(txs),
    do:
      txs
      |> Enum.map(&insAndOutsToStr(&1))
      |> Enum.join()

  def insAndOutsToStr(tx), do: TxIn.stringify(tx.txIns) <> TxOut.stringify(tx.txOuts)

  def processTransactions(tx, uTxOs) do
    if !validTx?(tx, uTxOs) do
      nil
    else
      newUTxOs = TxOut.toUTxO(tx.id, tx.txOuts)

      uTxOs
      |> Enum.concat(newUTxOs)
      |> Enum.uniq()
    end
  end

  def processTxForBlock(txs, uTxOs) do
    [_coinbaseTx | remainingTxs] = txs

    if !validAll?(remainingTxs, uTxOs) do
      nil
    else
      updateUnspentTxOuts(txs, uTxOs)
    end
  end

  def updateUnspentTxOuts(txs, uTxOs) do
    txs
    |> Enum.flat_map(&TxOut.toUTxO(&1.id, &1.txOuts))
    |> Enum.concat(uTxOs)
    |> Enum.uniq()
    |> filterNotConsumed()
  end

  def filterNotConsumed(uTxOs) do
    txIns = Server.getTxPool() |> Enum.flat_map(& &1.txIns)

    uTxOs |> Enum.filter(&notInTxIns?(&1, txIns))
  end

  def notInTxIns?(uTxO, txIns),
    do:
      txIns
      |> Enum.all?(&(!UTxO.equals?(&1, uTxO)))
end
