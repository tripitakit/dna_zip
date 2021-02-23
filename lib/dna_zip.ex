defmodule DnaZip do
  @moduledoc """

  """

  @spec compress(binary, binary) :: {:ok, binary}
  defdelegate compress(seq_id, sequence), to: DnaZip.Encoder

  @spec inflate(bitstring) ::
          {:ok,
           %{length: non_neg_integer, seq: bitstring, seq_id: binary, encoded_seq: bitstring()}}
  defdelegate inflate(compressed), to: DnaZip.Decoder

  @spec create_db(binary, binary) :: {:ok, binary}
  defdelegate create_db(name, multifasta), to: DnaZip.Database

  @spec read_db(binary) :: {:ok, list(map())}
  defdelegate read_db(file), to: DnaZip.Database
end
