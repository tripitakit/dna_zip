defmodule DnaZip do
  @moduledoc """
  Documentation for `DnaZip`.
  """

  @encode %{
    "A" => <<0::1*2>>,
    "T" => <<1::1*2>>,
    "G" => <<2::1*2>>,
    "C" => <<3::1*2>>
  }

  @decode %{
    0b00 => "A",
    0b01 => "T",
    0b10 => "G",
    0b11 => "C"
  }

  def compress(seq_id, sequence) do
    seq_bit_size = String.length(sequence) * 2

    seq_id =
      seq_id
      |> String.slice(0..20)
      |> String.pad_trailing(20)

    sequence
    |> String.split("", trim: true)
    |> Enum.reduce(
      <<seq_bit_size::4*8, seq_id::binary>>,
      fn nt, acc ->
        encoded_nt = @encode[nt]
        <<acc::bitstring, encoded_nt::bitstring>>
      end
    )
  end

  def inflate(compressed) do
    <<seq_bit_size::4*8, seq_id::binary-size(20), seq::bitstring>> = compressed

    seq_nt_length = seq_bit_size / 2

    {:ok,
     %{
       seq_id: seq_id,
       length: seq_nt_length,
       seq: inflate(seq, [])
     }}
  end

  defp inflate(<<>>, acc), do: acc

  defp inflate(encoded, acc) do
    {acc, tail} =
      case bit_size(encoded) do
        2 ->
          <<n1::1*2>> = encoded
          dn1 = @decode[n1]
          {"#{acc}#{dn1}", <<>>}

        4 ->
          <<n1::1*2, n2::1*2>> = encoded
          dn1 = @decode[n1]
          dn2 = @decode[n2]

          {"#{acc}#{dn1}#{dn2}", <<>>}

        6 ->
          <<n1::1*2, n2::1*2, n3::1*2>> = encoded
          dn1 = @decode[n1]
          dn2 = @decode[n2]
          dn3 = @decode[n3]

          {"#{acc}#{dn1}#{dn2}#{dn3}", <<>>}

        8 ->
          <<n1::1*2, n2::1*2, n3::1*2, n4::1*2>> = encoded
          dn1 = @decode[n1]
          dn2 = @decode[n2]
          dn3 = @decode[n3]
          dn4 = @decode[n4]

          {"#{acc}#{dn1}#{dn2}#{dn3}#{dn4}", <<>>}

        _ ->
          <<head::8, tail::bitstring>> = encoded
          <<n1::1*2, n2::1*2, n3::1*2, n4::1*2>> = <<head>>
          dn1 = @decode[n1]
          dn2 = @decode[n2]
          dn3 = @decode[n3]
          dn4 = @decode[n4]

          {"#{acc}#{dn1}#{dn2}#{dn3}#{dn4}", tail}
      end

    inflate(<<tail::bitstring>>, acc)
  end
end
