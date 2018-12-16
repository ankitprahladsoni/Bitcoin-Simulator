defmodule UTxO do
  import Utils

  def create(id, index, address, amount),
    do: %{txOutId: id, txOutIndex: index, address: address, amount: amount}

  def notInUTxOs(tx, uTxOs),
    do:
      tx.txIns
      |> Enum.all?(fn txIn -> !inUTxOs(txIn, uTxOs) end)

  def inUTxOs(txIn, uTxOs),
    do:
      findInUTxos(txIn, uTxOs)
      |> notNil?()

  def findInUTxos(txIn, uTxOs),
    do:
      uTxOs
      |> Enum.find(fn uTxO -> equals?(uTxO, txIn) end)

  def amountInUTxO(txIn, uTxOs),
    do:
      uTxOs
      |> Enum.filter(&equals?(txIn, &1))
      |> Enum.map(& &1.amount)

  def equals?(u1, u2), do: u1.txOutId == u2.txOutId && u1.txOutIndex == u2.txOutIndex

  def createUTxOsFor(uTxOs, amount), do: createUTxOsFor(uTxOs, amount, [])

  defp createUTxOsFor([], _amount, _uTxOs), do: raise("Unsufficient funds for transaction")

  defp createUTxOsFor([head | tail], amount, uTxOs) do
    uTxOs = [head | uTxOs]
    amount = amount - head.amount

    if amount > 0, do: createUTxOsFor(tail, amount, uTxOs), else: {uTxOs, amount * -1}
  end
end
