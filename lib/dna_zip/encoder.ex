defmodule DnaZip.Encoder do
  @encode %{
    "A" => <<0b00::size(2)>>,
    "T" => <<0b01::size(2)>>,
    "G" => <<0b10::size(2)>>,
    "C" => <<0b11::size(2)>>
  }

  @seq_id_size 124

  @spec compress(binary, binary) :: {:ok, bitstring}
  def compress(seq_id, sequence) when is_binary(seq_id) and is_binary(sequence) do
    seq_bit_size = String.length(sequence) * 2

    seq_id =
      seq_id
      |> String.slice(0..@seq_id_size)
      |> String.pad_trailing(@seq_id_size)

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
