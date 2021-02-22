defmodule DnaZip do
  @moduledoc """

  ## compress

  Compresses a binary DNA sequence into 2-bit-nucleotide encoded bitstring
  along with its bit-size and an identifier:

  <<seq_bit_size::4*8, seq_id:binary-size(124), seq:bitstring>>

  {:ok, compressed} = DnaZip.compress("Test-oligo", "GATGCGTGCCGAA")

  ## inflate

  Inflates a 2-bit compressed sequence's bitstring into a sequence Map.

  {:ok, %{length: 13, seq: "GATGCGTGCCGAA", seq_id: "Test-oligo"}}
  S
  """

  @spec compress(binary, binary) :: {:ok, bitstring}
  defdelegate compress(seq_id, sequence), to: DnaZip.Encoder

  @spec inflate(bitstring) ::
          {:ok, %{length: non_neg_integer, seq: bitstring, seq_id: binary}}
  defdelegate inflate(compressed), to: DnaZip.Decoder
end
