defmodule HashUtilTest do
  use ExUnit.Case
  doctest HashUtil

  test "hashs match" do
    assert HashUtil.hash("1") == HashUtil.hash("1")
  end

  test "hashs don't match" do
    assert HashUtil.hash("1") != HashUtil.hash("2")
  end

  test "valid hash based on difficulty" do
    hash = "000989898DEDASKFJAS"
    assert HashUtil.isValidHash?(hash)
  end

  test "invalid hash bsaed on difficulty" do
    hash = "00ASBALSBV90009090"
    refute HashUtil.isValidHash?(hash)
  end

  test "signature is verified" do
    {public, private1} = HashUtil.createPair()
    sign = HashUtil.getSign(private1, "data")
    assert HashUtil.verifySign(public, sign, "data")
  end

  test "signature not verified for different user" do
    {_public1, private1} = HashUtil.createPair()
    sign = HashUtil.getSign(private1, "data")

    {public2, _private2} = HashUtil.createPair()
    refute HashUtil.verifySign(public2, sign, "data")
  end

  test "signature not verified with different data" do
    {public, private} = HashUtil.createPair()
    sign = HashUtil.getSign(private, "data")
    refute HashUtil.verifySign(public, sign, "data2")
  end
end
