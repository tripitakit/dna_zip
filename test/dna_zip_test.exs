defmodule DnaZipTest do
  use ExUnit.Case
  doctest DnaZip

  test "compress a DNA sequence" do
    test_seq_id = "oligonucletide"
    test_seq = "ATGC"
    {:ok, compressed} = DnaZip.compress(test_seq_id, test_seq)

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

    {:ok, compressed} = DnaZip.compress(test_id, test_seq)

    {:ok,
     %{
       length: decoded_seq_lenght,
       seq_id: decoded_seq_id,
       seq: decoded_seq
     }} = DnaZip.inflate(compressed)

    assert decoded_seq_lenght == String.length(test_seq)
    assert decoded_seq_id == test_id
    assert decoded_seq == test_seq
  end
end
