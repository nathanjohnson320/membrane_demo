defmodule IcecastFile do
  @moduledoc """
  Element that creates a file and stores incoming buffers there (in binary format).
  """

  use Membrane.Sink
  alias Membrane.Buffer
  alias Membrane.File.CommonFile

  def_options(
    location: [
      type: :string,
      default: "",
      description: "Directory to write songs to"
    ],
    pre_process: [
      type: :function,
      description: "Function that handles input buffers and returns a new state"
    ]
  )

  def_input_pad(:input, demand_unit: :buffers, caps: :any)

  @impl true
  def handle_init(%__MODULE__{location: location, pre_process: pre_process}) do
    {:ok,
     %{
       location: location,
       pre_process: pre_process,
       fd: nil,
       current_meta: nil
     }}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {{:ok, demand: :input}, state}
  end

  @impl true
  def handle_write(
        :input,
        %Buffer{payload: payload} = buffer,
        _ctx,
        %{pre_process: pre_process} = state
      ) do
    state = pre_process.(buffer, state)

    bin_payload = Membrane.Payload.to_binary(payload)

    with :ok <- CommonFile.binwrite(state.fd, bin_payload) do
      {{:ok, demand: :input}, state}
    else
      {:error, _reason} ->
        {{:ok, demand: :input}, state}
    end
  end

  @impl true
  def handle_prepared_to_stopped(_ctx, state), do: CommonFile.close(state)

  @impl true
  def handle_other(:meta, _ctx, state) do
    {:ok, state}
  end
end
