defmodule DnaZip.Encoder do
  @encode %{
    "A" => <<0b00::size(2)>>,
    "C" => <<0b01::size(2)>>,
    "G" => <<0b10::size(2)>>,
    "T" => <<0b11::size(2)>>
  }

  @seq_id_size 124

  @spec compress(binary, binary) :: {:ok, binary}
  def compress(seq_id, sequence) when is_binary(seq_id) and is_binary(sequence) do
    seq_bit_size = String.length(sequence) * 2

    seq_id =
      seq_id
      |> String.slice(0..(@seq_id_size - 1))
      |> String.pad_trailing(@seq_id_size)

    encoded =
      sequence
      |> String.split("", trim: true)
      |> Enum.reduce(
        <<>>,
        fn nt, acc ->
          encoded_nt = @encode[nt]
          <<acc::bitstring, encoded_nt::bitstring>>
        end
      )

    # padding the last byte with zeros
    padding_bits = 8 - rem(bit_size(encoded), 8)

    encoded =
      if padding_bits < 8 do
        <<encoded::bitstring, 0::size(padding_bits)>>
      else
        encoded
      end

    {:ok, <<seq_bit_size::4*8, seq_id::binary, encoded::binary>>}
  end
end
