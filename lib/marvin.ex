defmodule Marvin do
  alias Marvin.Timer
  alias Marvin.Runner
  alias Marvin.Config
  alias Marvin.Reporter
  alias Marvin.HttpClient

  def run(config) do
    setup_program(config)
    run_program()
    start_countdown()
    print_result()
  end

  def setup_program(config) do
    config = Config.load(config)

    Supervisor.start_link(
      [
        {Timer, config.duration},
        {Runner, [config.scenarios]},
        {Reporter, []},
        HttpClient.child_spec()
      ],
      strategy: :one_for_one
    )
  end

  def run_program() do
    Runner.run_workers()
  end

  def start_countdown() do
    Timer.countdown(Runner, Reporter)
  end

  defp print_result() do
    Reporter.print_result()
  end
end
