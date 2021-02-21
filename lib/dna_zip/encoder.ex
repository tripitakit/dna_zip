defmodule DnaZip.Encoder do
  @encode %{
    "A" => <<0::1*2>>,
    "T" => <<1::1*2>>,
    "G" => <<2::1*2>>,
    "C" => <<3::1*2>>
  }

  def compress(seq_id, sequence) do
    seq_bit_size = String.length(sequence) * 2

    seq_id =
      seq_id
      |> String.slice(0..20)
      |> String.pad_trailing(20)

    compressed =
      sequence
      |> String.split("", trim: true)
      |> Enum.reduce(
        <<seq_bit_size::4*8, seq_id::binary>>,
        fn nt, acc ->
          encoded_nt = @encode[nt]
          <<acc::bitstring, encoded_nt::bitstring>>
        end
      )

    {:ok, compressed}
  end
end
