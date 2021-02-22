defmodule DnaZip do
  @spec compress(binary, binary) :: {:ok, bitstring}
  defdelegate compress(seq_id, sequence), to: DnaZip.Encoder

  @spec inflate(bitstring) ::
          {:ok, %{length: non_neg_integer, seq: bitstring, seq_id: binary}}
  defdelegate inflate(compressed), to: DnaZip.Decoder

  @spec create_db(binary, binary) :: {:ok, binary}
  defdelegate create_db(name, multifasta_path), to: DnaZip.Database
end
