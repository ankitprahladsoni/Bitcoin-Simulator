defmodule HashUtil do
  @difficulty 3
  def hash(data), do: :crypto.hash(:sha256, data) |> Base.encode16()

  def isValidHash?(hash),
    do: String.slice(hash, 0..(@difficulty - 1)) == String.duplicate("0", @difficulty)

  def createPair(), do: :crypto.generate_key(:ecdh, :secp256k1)

  def getSign(private_key, data),
    do: :crypto.sign(:ecdsa, :sha256, data, [private_key, :secp256k1])

  def verifySign(public_key, sign, data),
    do: :crypto.verify(:ecdsa, :sha256, data, sign, [public_key, :secp256k1])
end
