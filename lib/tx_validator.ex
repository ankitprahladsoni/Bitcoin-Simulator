defmodule TxValidator do
  @cbamt 50

  def validCoinbase?(coinbaseTx, index) do
    coinbaseTx.txIns |> length() == 1 and coinbaseTx.txOuts |> length() == 1 and
      hd(coinbaseTx.txIns).txOutIndex == index and hd(coinbaseTx.txOuts).amount == @cbamt
  end

  def validAll?(txs, uTxOs), do: txs |> Enum.all?(&validTx?(&1, uTxOs))

  def validTx?(tx, uTxOs) do
    tx.id == Transaction.createTxId(tx) and insAndOutAmountMatches?(tx, uTxOs) and
      TxIn.allValid?(tx.txIns, uTxOs)
  end

  def insAndOutAmountMatches?(tx, uTxOs) do
    TxIn.getAmount(tx.txIns, uTxOs) == TxOut.getAmount(tx.txOuts)
  end
end
