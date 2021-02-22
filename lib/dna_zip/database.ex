defmodule DnaZip.Database do
  alias BioElixir.{Seq, SeqIO}
  alias DnaZip.{Encoder, Decoder}
  require Logger

  def create_db(name, multifasta_path) do
    [%Seq{} | _] = sequences = SeqIO.read_fasta_file(multifasta_path)

    outfile = "tmp/#{name}.dnz"

    sequences
    |> Stream.map(&encode_seq/1)
    |> Stream.into(File.stream!(outfile))
    |> Stream.run()

    {:ok, outfile}
  end

  def read_db(file) do
    {:ok, pid} = :file.open(file, [:read, :binary])

    pread(pid, 0, 4, [])
  end

  defp encode_seq(%Seq{} = s) do
    {:ok, encoded} = Encoder.compress(s.display_id, s.seq)
    encoded
  end

  def pread(pid, nil, nil, acc) do
    :file.close(pid)
    {:ok, acc}
  end

  def pread(pid, start, len, acc) do
    case :file.pread(pid, start, len) do
      {:ok, seq_bit_size} ->
        <<sbs::4*8>> = seq_bit_size

        seq_bytes_size =
          if rem(sbs, 8) > 0 do
            div(sbs, 8) + 1
          else
            div(sbs, 8)
          end

        seq_bytes_size = seq_bytes_size + 128
        {:ok, data} = :file.pread(pid, start, seq_bytes_size)

        {:ok, seq} = Decoder.inflate(data)

        acc = [seq | acc]

        next_start = start + seq_bytes_size
        pread(pid, next_start, 4, acc)

      :eof ->
        pread(pid, nil, nil, acc)
    end
  end
end
