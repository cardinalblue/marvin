defmodule Marvin do
  alias Marvin.Runner
  alias Marvin.Config
  alias Marvin.Reporter
  alias Marvin.HttpClient

  @spec run(Config.config()) :: :ok
  def run(config) do
    setup_program(config.scenarios)

    start_time = start_program()
    countdown(config.duration)
    stop_time = stop_program()

    print_result(start_time, stop_time)
  end

  @spec setup_program([Config.scenario()]) :: [any()]
  def setup_program(scenarios) do
    Supervisor.start_link(
      [
        {Runner, []},
        {Reporter, []},
        HttpClient.child_spec()
      ],
      strategy: :one_for_one
    )

    Runner.setup_workers(scenarios)
  end

  @spec start_program :: float()
  def start_program() do
    Runner.run_workers()

    :erlang.system_time() / 1000
  end

  @spec countdown(Config.duration()) :: :ok
  def countdown(duration) do
    :timer.sleep(duration * 1000)
  end

  @spec stop_program :: float()
  def stop_program() do
    Runner.stop()

    :erlang.system_time() / 1000
  end

  @spec print_result(float(), float()) :: :ok
  def print_result(start_time, stop_time) do
    Reporter.print_result(start_time, stop_time)
  end
end
