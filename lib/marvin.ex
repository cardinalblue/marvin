defmodule Marvin do
  alias Marvin.Runner
  alias Marvin.Reporter
  alias Marvin.HttpClient

  def run(config) do
    setup_program(config.scenarios)
    start_time = start_program()
    countdown(config.duration)
    stop_time = stop_program()
    print_result(start_time, stop_time)
  end

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

  def start_program() do
    Runner.run_workers()

    :erlang.system_time() / 1000
  end

  def countdown(duration) do
    :timer.sleep(duration * 1000)
  end

  def stop_program() do
    Runner.stop()

    :erlang.system_time() / 1000
  end

  def print_result(start_time, stop_time) do
    Reporter.print_result(start_time, stop_time)
  end
end
