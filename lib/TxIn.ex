defmodule TxIn do
  def create(sign, txOutId, txOutIndex),
    do: %{sign: sign, txOutId: txOutId, txOutIndex: txOutIndex}

  def stringify(txIns),
    do:
      txIns
      |> Enum.map(fn x -> to_string(x.txOutId) <> to_string(x.txOutIndex) end)
      |> Enum.join()

  def getAmount(txIns, uTxOs),
    do:
      txIns
      |> Enum.flat_map(fn txIn -> UTxO.amountInUTxO(txIn, uTxOs) end)
      |> Enum.sum()

  def allValid?(txIns, uTxOs), do: txIns |> Enum.all?(&valid?(&1, uTxOs))

  defp valid?(txIn, uTxOs) do
    referenced = UTxO.findInUTxos(txIn, uTxOs)
    referenced != nil && HashUtil.verifySign(referenced.address, txIn.sign, referenced.txOutId)
  end
end
