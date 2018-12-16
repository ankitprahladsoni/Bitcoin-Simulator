defmodule Wallet do
  import HashUtil
  import Server

  def sendTransaction(from_tuple, to, amount) do
    newTx = createTransaction(from_tuple, to, amount)
    Server.addToTransactionPool(newTx)

    Transaction.processTransactions(newTx, getUTxOs())
    |> updateUTxOs()
  end

  defp createTransaction({from, private_key}, to, amount) do
    {uTxOs, leftOver} = getUTxOsToUnlock(from, amount)

    txIns = getSignedTxIns(uTxOs, private_key)

    txOuts = createTxOutsForTransaction(to, amount, from, leftOver)
    Transaction.create(txIns, txOuts)
  end

  defp getUTxOsToUnlock(from, amount),
    do: unConsumedUTxOsOf(from) |> UTxO.createUTxOsFor(amount)

  defp getSignedTxIns(uTxOs, private_key),
    do:
      uTxOs
      |> Enum.map(fn t ->
        TxIn.create(getSign(private_key, t.txOutId), t.txOutId, t.txOutIndex)
      end)

  defp createTxOutsForTransaction(to, amount, from, leftOver) do
    txOutForTo = TxOut.create(to, amount)

    if leftOver > 0 do
      txOutForFrom = TxOut.create(from, leftOver)
      [txOutForFrom, txOutForTo]
    else
      [txOutForTo]
    end
  end

  def balance(address) do
    unConsumedUTxOsOf(address)
    |> Enum.map(& &1.amount)
    |> Enum.sum()
  end

  defp unConsumedUTxOsOf(address) do
    Server.getUTxOs()
    |> Enum.filter(fn uTxO -> uTxO.address == address end)
    |> Transaction.filterNotConsumed()
  end
end
