defmodule DnaZip.Decoder do
  @decode %{
    0b00 => "A",
    0b01 => "T",
    0b10 => "G",
    0b11 => "C"
  }

  def inflate(compressed) do
    <<seq_bit_size::4*8, seq_id::binary-size(20), seq::bitstring>> = compressed

    seq_nt_length = div(seq_bit_size, 2)

    {:ok,
     %{
       seq_id: String.trim_trailing(seq_id, " "),
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
