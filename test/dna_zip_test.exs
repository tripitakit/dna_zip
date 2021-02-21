defmodule DnaZipTest do
  use ExUnit.Case
  doctest DnaZip

  test "compress a DNA sequence" do
    test_seq_id = "oligonucletide"
    test_seq = "ATGC"
    compressed = DnaZip.compress(test_seq_id, test_seq)

    <<seq_bit_size::binary-size(4), seq_id::binary-size(20), a::1*2, t::1*2, g::1*2, c::1*2>> =
      compressed

    assert seq_id == String.pad_trailing(test_seq_id, 20)
    assert seq_bit_size == <<8::4*8>>
    assert a == 0b00
    assert t == 0b01
    assert g == 0b10
    assert c == 0b11
  end

  test "inflate encoded DNA sequence" do
    test_seq = "GATTACA"
    test_id = "gattaca-test"

    compressed = DnaZip.compress(test_id, test_seq)

    {:ok, %{} = inflated} = DnaZip.inflate(compressed)

    assert inflated.length == String.length(test_seq)
    assert inflated.seq_id == String.pad_trailing(test_id, 20)
    assert inflated.seq == test_seq
  end
end
