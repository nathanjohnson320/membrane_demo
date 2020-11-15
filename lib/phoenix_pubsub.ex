defmodule PhoenixPubSub do
  @moduledoc """
  {:ok, pid} = PhoenixPubSub.start_link("./song.mp3")
  PhoenixPubSub.play(pid)
  """
  use Membrane.Pipeline

  alias Membrane.File
  alias Membrane.Element.MPEGAudioParse
  alias MembraneDemoWeb.Endpoint

  @impl true
  def handle_init(path) do
    children = %{
      file: %File.Source{
        location: path
      },
      parser: %MPEGAudioParse.Parser{skip_until_frame: true},
      broadcaster: MPEGSink
    }

    links = [
      link(:file) |> to(:parser) |> to(:broadcaster)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end

  @impl true
  def handle_notification(
        {MPEGSink, :complete},
        _element,
        _context,
        state
      ) do
    Endpoint.broadcast_from(self(), "song", "done", %{})
    {:ok, state}
  end

  @impl true
  def handle_notification(
        {MPEGSink, {:chunk, chunk}},
        :broadcaster,
        _ctx,
        state
      ) do
    IO.inspect(chunk, label: "CHUNK")
    Endpoint.broadcast_from(self(), "song", "chunk", %{data: chunk})

    {:ok, state}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    IO.inspect("Song started.")
    {:ok, state}
  end
end
