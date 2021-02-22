defmodule DnaZip.Database do
  alias BioElixir.{Seq, SeqIO}
  alias DnaZip.{Encoder}

  def create_db(name, multifasta_path) do
    [%Seq{} | _] = sequences = SeqIO.read_fasta_file(multifasta_path)

    outfile = "tmp/#{name}.dnazip"

    sequences
    |> Stream.map(&encode_seq/1)
    |> Stream.into(File.stream!(outfile))
    |> Stream.run()

    {:ok, outfile}
  end

  defp encode_seq(%Seq{} = s) do
    {:ok, encoded} = Encoder.compress(s.display_id, s.seq)
    encoded
  end
end
