defmodule Epic do
  @moduledoc """
  {:ok, pid} = Epic.start_link("http://jenny.torontocast.com:8064/stream")
  Epic.play(pid)
  """
  use Membrane.Pipeline

  alias Membrane.File.CommonFile

  @impl true
  def handle_init(url) do
    children = %{
      raw: %Membrane.Hackney.Source{
        location: url,
        headers: [{"Icy-MetaData", "1"}],
        hackney_opts: [follow_redirect: true]
      },
      ice: %Icecast{
        location: url,
        parser: &parse_meta/1
      },
      sink: %IcecastFile{
        location: "./songs/",
        pre_process: &pre_process/2
      }
    }

    links = [
      link(:raw)
      |> to(:ice)
      |> to(:sink)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end

  def parse_meta(meta) do
    meta
    |> String.split(";")
    |> Enum.reduce(%{}, fn
      <<"StreamUrl", _rest::binary>> = uri, acc ->
        uri |> URI.decode_query() |> Map.merge(acc) |> Map.delete("StreamUrl")

      _el, acc ->
        acc
    end)
  end

  def pre_process(%Membrane.Buffer{metadata: meta}, state) do
    current_meta = state.current_meta

    {:ok, state} =
      if not is_nil(state.fd) and current_meta not in [nil, %{}] and meta not in [nil, %{}] and
           meta != current_meta do
        # Close the file
        {:ok, state} = CommonFile.close(state)

        # Rename it to the name of the song
        File.rename(
          Path.expand("#{state.location}#{output_filename(nil)}"),
          Path.expand("#{state.location}#{output_filename(current_meta)}")
        )

        {:ok, state}
      else
        {:ok, state}
      end

    {:ok, state} =
      if is_nil(state.fd) and meta != %{} and meta != current_meta do
        {:ok, state} =
          CommonFile.open(Path.expand("#{state.location}#{output_filename(nil)}"), :write, state)

        {:ok, state}
      else
        {:ok, state}
      end

    if not is_nil(meta) and meta != %{} do
      %{state | current_meta: meta}
    else
      state
    end
  end

  defp output_filename(%{
         "album" => album,
         "artist" => artist,
         "title" => title
       }) do
    "#{artist} - #{album} - #{title}.mp3"
  end

  defp output_filename(_), do: "incomplete.mp3"
end
