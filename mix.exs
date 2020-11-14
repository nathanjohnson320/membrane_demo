defmodule MembraneDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :membrane_demo,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MembraneDemo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.6"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:membrane_core, "~> 0.6.0", override: true},
      {:membrane_file_plugin, "~> 0.5.0"},
      {:membrane_hackney_plugin, "~> 0.4.0"},
      {:membrane_ffmpeg_swresample_plugin, "~> 0.4.0"},
      {:membrane_mp3_mad_plugin, "~> 0.4.0"},
      {:membrane_portaudio_plugin, "~> 0.4.0"},
      {:membrane_element_udp, "~> 0.3.2"},
      {:membrane_element_ffmpeg_h264, "~> 0.4.0"},
      {:membrane_http_adaptive_stream_plugin, "~> 0.1.0"},
      {:membrane_aac_format, "~> 0.1.0"},
      {:membrane_mp4_plugin, "~> 0.3.0"},
      {:membrane_rtp_aac_plugin, "~> 0.1.0-alpha"},
      {:membrane_rtp_plugin, "~> 0.4.0-alpha"},
      {:membrane_rtp_h264_plugin, "~> 0.3.0-alpha"},
      {:membrane_element_tee, "~> 0.3.2"},
      {:membrane_element_fake, "~> 0.3"},
      {:membrane_aac_plugin, "~> 0.4.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
