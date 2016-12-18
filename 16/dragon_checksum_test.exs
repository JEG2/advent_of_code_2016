ExUnit.start

defmodule DragonChecksumTest do
  use ExUnit.Case

  test "it builds dragon curves" do
    assert "100" == DragonChecksum.dragon_curve("1")
    assert "001" == DragonChecksum.dragon_curve("0")
    assert "11111000000" == DragonChecksum.dragon_curve("11111")
    assert "1111000010100101011110000" == DragonChecksum.dragon_curve("111100001010")
  end

  test "it computes a checksum" do
    assert "100" == DragonChecksum.checksum("110010110100")
  end

  test "it computes the full process" do
    assert "01100" == DragonChecksum.compute("10000", 20)
  end
end
