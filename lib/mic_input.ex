defmodule MicInput do
  @moduledoc """
  {:ok, pid} = MicInput.start_link("./mic.mp3")
  MicInput.play(pid)
  MicInput.stop(pid)
  """
  use Membrane.Pipeline

  @mic System.get_env("MIC_DEVICE", "default")

  @impl true
  def handle_init(path) do
    endpoint_id =
      if @mic == "default" do
        :default
      else
        Integer.parse(@mic) |> elem(0)
      end

    children = %{
      source: %Membrane.PortAudio.Source{
        endpoint_id: endpoint_id
      },
      resample: %Membrane.FFmpeg.SWResample.Converter{
        output_caps: %Membrane.Caps.Audio.Raw{
          format: :s32le,
          sample_rate: 44100,
          channels: 2
        }
      },
      mp3: %Membrane.MP3.Lame.Encoder{},
      sink: %Membrane.File.Sink{
        location: path
      }
    }

    links = [
      link(:source) |> to(:resample) |> to(:mp3) |> to(:sink)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end
end
