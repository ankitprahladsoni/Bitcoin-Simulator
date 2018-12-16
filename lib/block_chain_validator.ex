defmodule BlockChainValidator do
  def validBlock?(block) do
    calculatedHash = BlockChain.blockHash(block, block.nonce)

    HashUtil.isValidHash?(calculatedHash) && calculatedHash == block.hash &&
      validWithPrevious?(block, Server.getLastestBlock()) &&
      TxValidator.validCoinbase?(hd(block.blockData), block.index)
  end

  def validWithPrevious?(block, previous) do
    (previous != nil && previous.index + 1 == block.index && previous.hash == block.prvHash) ||
      (previous == nil && block.index == 0 && block.prvHash == "")
  end
end
