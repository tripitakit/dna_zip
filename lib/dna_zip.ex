defmodule DnaZip do
  @moduledoc """

  ## compress

  compress binary DNA sequences with a 2-bit-nucleotide encoding stored
  as a bitstring along with the sequence bit-size and a 20 characters identifier.

  <<seq_bit_size::4*8, seq_id:binary-size(20), seq:bitstring>>

   iex> {:ok, compressed} = DnaZip.compress("Test-oligo", "GATGCGTGCCGAA")

  {:ok, <<0, 0, 0, 26, 84, 101, 115, 116, 45, 111, 108, 105, 103, 111, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 134, 230, 248, 0::size(2)>>}



  ## inflate

  inflate a compressed sequence's bitstring to ccess the internal properties:

  iex> {:ok, inflated} = DnaZip.inflate(<<0, 0, 0, 26, 84, 101, 115, 116, 45, 111, 108, 105, 103, 111, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 134, 230, 248, 0::size(2)>>)

  {:ok, %{length: 13, seq: "GATGCGTGCCGAA", seq_id: "Test-oligo"}}
  """

  defdelegate compress(seq_id, sequence), to: DnaZip.Encoder

  defdelegate inflate(compressed), to: DnaZip.Decoder
end
