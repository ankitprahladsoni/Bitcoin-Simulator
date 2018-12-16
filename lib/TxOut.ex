defmodule TxOut do
  def create(address, amount), do: %{address: address, amount: amount}

  def stringify(txOuts),
    do:
      txOuts
      |> Enum.map(fn x -> x.address <> to_string(x.amount) end)
      |> Enum.join()

  def toUTxO(id, txOuts),
    do:
      txOuts
      |> Enum.with_index()
      |> Enum.map(fn {x, index} -> UTxO.create(id, index, x.address, x.amount) end)

  def getAmount(txOuts),
    do:
      txOuts
      |> Enum.map(& &1.amount)
      |> Enum.sum()
end
