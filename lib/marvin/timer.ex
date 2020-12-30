defmodule Marvin.Timer do
  use Agent, restart: :permanent, shutdown: 10_000

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(duration) do
    init_state = [duration: duration]
    Agent.start_link(fn -> init_state end, name: __MODULE__)
  end

  def countdown(runner, reporter) do
    start_time = :erlang.system_time() / 1000

    :timer.sleep(Agent.get(__MODULE__, & &1[:duration]) * 1000)
    stop_runner(runner)

    finish_time = :erlang.system_time() / 1000

    reporter.log_duration(start: start_time, finish: finish_time)
  end

  def stop_runner(runner) do
    # TODO: config proper timeout value (before the :shutdown command becomes :kill)
    # TODO: Ensure it's entire shut down
    runner.stop
  end
end
