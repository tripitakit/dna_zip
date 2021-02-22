defmodule DnaZipTest do
  use ExUnit.Case
  doctest DnaZip

  @seq_id_size 124

  test "compress a DNA sequence" do
    test_seq_id = "oligonucletide"
    test_seq = "ATGC"
    {:ok, compressed} = DnaZip.compress(test_seq_id, test_seq)

    <<seq_bit_size::binary-size(4), seq_id::binary-size(@seq_id_size), a::1*2, t::1*2, g::1*2,
      c::1*2>> = compressed

    assert seq_id == String.pad_trailing(test_seq_id, @seq_id_size)
    assert seq_bit_size == <<8::4*8>>
    assert a == 0b00
    assert t == 0b01
    assert g == 0b10
    assert c == 0b11
  end

  test "inflate a compressed sequence bitstring" do
    test_seq = "GATTACAGC"
    test_id = "gattacagc-test"

    {:ok, compressed} = DnaZip.compress(test_id, test_seq)

    {:ok,
     %{
       length: decoded_seq_lenght,
       seq_id: decoded_seq_id,
       seq: decoded_seq
     }} = DnaZip.inflate(compressed)

    assert decoded_seq_lenght == String.length(test_seq)
    assert decoded_seq_id == test_id
    assert decoded_seq == test_seq
  end

  test "inflate a compressed sequence bitstring with 130char long label" do
    test_seq = "GATTACAGC"

    test_id =
      "test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-test-1234567890"

    {:ok, compressed} = DnaZip.compress(test_id, test_seq)

    {:ok,
     %{
       length: decoded_seq_lenght,
       seq_id: decoded_seq_id,
       seq: decoded_seq
     }} = DnaZip.inflate(compressed)

    assert decoded_seq_lenght == String.length(test_seq)
    assert decoded_seq_id == String.slice(test_id, 0..(@seq_id_size - 1))
    assert decoded_seq == test_seq
  end

  test "1000 random-lenght random-sequence compress/inflate " do
    for i <- 333..999 do
      test_seq = random_seq()
      test_id = "random-test-#{i}"

      {:ok, compressed} = DnaZip.compress(test_id, test_seq)

      {:ok,
       %{
         length: decoded_seq_lenght,
         seq_id: decoded_seq_id,
         seq: decoded_seq
       }} = DnaZip.inflate(compressed)

      assert decoded_seq_lenght == String.length(test_seq)
      assert decoded_seq_id == test_id
      assert decoded_seq == test_seq
    end
  end

  test "create db from multifasta file and read it back" do
    input_file = "tmp/mixedlength-longlabels.fasta"
    input_squences = BioElixir.SeqIO.read_fasta_file(input_file)

    {:ok, mixedlong_dnz} = DnaZip.create_db("mixedlong", input_file)

    assert mixedlong_dnz == "tmp/mixedlong.dnz"

    {:ok, test_sequences} = DnaZip.read_db(mixedlong_dnz)

    assert Enum.count(input_squences) == Enum.count(test_sequences)

    %BioElixir.Seq{} = first_input = List.first(input_squences)
    last_test = List.last(test_sequences)

    assert last_test.seq == first_input.seq
    assert last_test.seq_id == String.slice(first_input.display_id, 0..(@seq_id_size - 1))
  end

  defp random_seq() do
    len = :random.uniform(512) + :random.uniform(512)

    Enum.reduce(
      1..len,
      "",
      fn _i, acc ->
        [nt] = ["G", "A", "T", "C"] |> Enum.take_random(1)

        acc <> nt
      end
    )
  end
end
