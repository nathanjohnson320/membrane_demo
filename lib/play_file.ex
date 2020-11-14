defmodule PlayFile do
  @moduledoc """
  {:ok, pid} = PlayFile.start_link("./song.mp3")
  PlayFile.play(pid)
  """
  use Membrane.Pipeline

  @impl true
  def handle_init(path_to_mp3) do
    children = %{
      file: %Membrane.File.Source{location: path_to_mp3},
      decoder: Membrane.MP3.MAD.Decoder,
      converter: %Membrane.FFmpeg.SWResample.Converter{
        output_caps: %Membrane.Caps.Audio.Raw{
          format: :s16le,
          sample_rate: 48000,
          channels: 2
        }
      },
      portaudio: Membrane.PortAudio.Sink
    }

    links = [
      link(:file) |> to(:decoder) |> to(:converter) |> to(:portaudio)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end
end
