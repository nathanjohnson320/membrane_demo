defmodule AWSFile do
  @moduledoc """
  {:ok, pid} = AWSFile.start_link("uploads/song.mp3")
  AWSFile.play(pid)
  """
  use Membrane.Pipeline

  @bucket System.get_env("BUCKET", "")

  @impl true
  def handle_init(object_path) do
    {:ok, url} = ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, @bucket, object_path)

    children = %{
      file: %Membrane.Hackney.Source{
        location: url,
        hackney_opts: [follow_redirect: true]
      },
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
