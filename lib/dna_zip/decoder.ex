defmodule DnaZip.Decoder do
  require Logger
  require Integer

  @decode %{
    0b00 => "A",
    0b01 => "T",
    0b10 => "G",
    0b11 => "C"
  }

  @seq_id_size 124

  def inflate(compressed) do
    <<seq_bit_size::4*8, seq_id::binary-size(@seq_id_size), seq::bitstring>> = compressed

    seq_nt_length = div(seq_bit_size, 2)

    maybe_trim =
      if rem(seq_nt_length, 4) == 0 do
        seq_nt_length
      else
        seq_nt_length - 1
      end

    nt_seq = inflate_seq(seq, "") |> String.slice(0..maybe_trim)

    {:ok,
     %{
       seq_id: String.trim_trailing(seq_id, " "),
       length: seq_nt_length,
       seq: nt_seq
     }}
  end

  defp inflate_seq(<<>>, acc), do: acc

  defp inflate_seq(encoded, acc) do
    {acc, tail} =
      case bit_size(encoded) do
        2 ->
          <<n1::size(2)>> = encoded
          dn1 = @decode[n1]
          {"#{acc}#{dn1}", <<>>}

        4 ->
          <<n1::size(2), n2::size(2)>> = encoded
          dn1 = @decode[n1]
          dn2 = @decode[n2]

          {"#{acc}#{dn1}#{dn2}", <<>>}

        6 ->
          <<n1::size(2), n2::size(2), n3::size(2)>> = encoded
          dn1 = @decode[n1]
          dn2 = @decode[n2]
          dn3 = @decode[n3]

          {"#{acc}#{dn1}#{dn2}#{dn3}", <<>>}

        8 ->
          <<n1::size(2), n2::size(2), n3::size(2), n4::size(2)>> = encoded
          dn1 = @decode[n1]
          dn2 = @decode[n2]
          dn3 = @decode[n3]
          dn4 = @decode[n4]

          {"#{acc}#{dn1}#{dn2}#{dn3}#{dn4}", <<>>}

        _ ->
          <<head::size(8), tail::bitstring>> = encoded
          <<n1::size(2), n2::size(2), n3::size(2), n4::size(2)>> = <<head>>
          dn1 = @decode[n1]
          dn2 = @decode[n2]
          dn3 = @decode[n3]
          dn4 = @decode[n4]

          {"#{acc}#{dn1}#{dn2}#{dn3}#{dn4}", tail}
      end

    inflate_seq(<<tail::bitstring>>, acc)
  end
end
