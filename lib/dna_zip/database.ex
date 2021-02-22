defmodule DnaZip.Database do
  alias BioElixir.{Seq, SeqIO}
  alias DnaZip.{Encoder}
  require Logger

  def create_db(name, multifasta_path) do
    [%Seq{} | _] = sequences = SeqIO.read_fasta_file(multifasta_path)

    outfile = "tmp/#{name}.dnazip"

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

  def pread(pid, start, len, acc) do
    case :file.pread(pid, start, len) do
      {:ok, seq_bit_size} ->
        <<sbs::4*8>> = seq_bit_size
        Logger.info("1> START: #{start} LENGTH: #{len} SBS: #{sbs}")

        seq_bytes_n =
          if rem(sbs, 8) > 0 do
            div(sbs, 8) + 1
          else
            div(sbs, 8)
          end

        seq_bytes_n = seq_bytes_n + 128
        Logger.info("2> START: #{start} LENGTH: #{seq_bytes_n}")
        {:ok, data} = :file.pread(pid, start, seq_bytes_n)

        {:ok, seq} = DnaZip.Decoder.inflate(data)
        Logger.info("3> #{seq.seq_id} #{seq.length} #{seq.seq}")

        acc = [seq | acc]

        next_start = start + seq_bytes_n
        Logger.info("4> NEXT START: #{next_start} LENGTH: 4")
        pread(pid, next_start, 4, acc)

      :eof ->
        :file.close(pid)
        Logger.info("EOF")
        acc
    end
  end
end
