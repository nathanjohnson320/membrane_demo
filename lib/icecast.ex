defmodule Icecast do
  use Membrane.Filter

  def_options(
    location: [
      type: :string,
      default: "",
      description: "The url of an icecast stream"
    ],
    parser: [
      type: :function,
      description: "Function that parses strings"
    ]
  )

  def_input_pad(:input, caps: :any, demand_unit: :buffers, mode: :pull, availability: :always)

  def_output_pad(:output, caps: :any, mode: :pull, availability: :always)

  @impl true
  def handle_init(%__MODULE__{location: url, parser: parser}) do
    {:ok, 200, headers, _ref} = :hackney.request(:get, url, [{"Icy-MetaData", "1"}])

    {bitrate, ""} =
      headers
      |> get_header("icy-br")
      |> Integer.parse()

    {frequency, ""} =
      headers
      |> get_header("icy-sr")
      |> Integer.parse()

    {meta_interval, ""} =
      headers
      |> get_header("icy-metaint")
      |> Integer.parse()

    {:ok,
     %{
       headers: headers,
       bitrate: bitrate,
       frequency: frequency,
       meta_interval: meta_interval,
       parsed_bytes: <<>>,
       parser: parser
     }}
  end

  @impl true
  def handle_prepared_to_stopped(_ctx, state) do
    {:ok, %{state | parsed_bytes: <<>>}}
  end

  defp get_header(headers, header),
    do:
      Enum.find_value(headers, fn
        {name, value} when name == header ->
          value

        _ ->
          nil
      end)

  @impl true
  def handle_demand(:output, size, :buffers, _context, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(
        :input,
        %Membrane.Buffer{payload: payload},
        _context,
        %{parsed_bytes: parsed_bytes, meta_interval: meta_interval, parser: parser} = state
      )
      when byte_size(parsed_bytes) >= meta_interval do
    # every meta_interval we need to parse out the meta data
    # the length of meta data is 16*first byte for example
    # epic rock radio gives us 14 so the total string length is 224 bytes
    # send the audio out the other side

    parsed_bytes = parsed_bytes <> payload

    size = :binary.at(parsed_bytes, meta_interval) * 16

    <<_base::binary-size(meta_interval), _size::integer, meta::binary-size(size), rest::binary>> =
      parsed_bytes

    meta = String.trim_trailing(meta, <<0>>)

    meta =
      if meta != "" do
        parser.(meta)
      else
        nil
      end

    {{:ok,
      buffer:
        {:output,
         %Membrane.Buffer{
           payload: rest,
           metadata: meta
         }}}, %{state | parsed_bytes: rest}}
  end

  def handle_process(:input, %Membrane.Buffer{} = buffer, _ctx, state) do
    {{:ok, buffer: {:output, buffer}},
     %{state | parsed_bytes: state.parsed_bytes <> buffer.payload}}
  end
end
