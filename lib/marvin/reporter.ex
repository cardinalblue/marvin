defmodule Marvin.Reporter do
  use Agent, restart: :permanent, shutdown: 10_000

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_) do
    init_state = %{
      start: nil,
      finish: nil,
      n_failed_requests: 0,
      n_successful_requests: 0
    }

    Agent.start_link(fn -> init_state end, name: __MODULE__)
  end

  def log_duration(start: start, finish: finish) do
    update_state(:start, start)
    update_state(:finish, finish)
  end

  def log_result(successful: successful, failed: failed) do
    increase_count(:n_successful_requests, successful)
    increase_count(:n_failed_requests, failed)
  end

  def print_result() do
    n_successful_requests = get_state(:n_successful_requests)
    n_failed_requests = get_state(:n_failed_requests)

    start_time = get_state(:start)
    finish_time = get_state(:finish)
    duration = ((finish_time - start_time) / 1_000_000) |> Float.round(2)

    rps = (n_successful_requests / duration) |> round
    rpm = (rps * 60 / 1000) |> Float.round(1)

    IO.puts("==========================================================")
    IO.puts("# Successful requests: #{n_successful_requests}")
    IO.puts("# Failed requests: #{n_failed_requests}")
    IO.puts("# Duration: #{duration} seconds")
    IO.puts("# Throughput: #{rps} rps, #{rpm}K rpm")
    IO.puts("==========================================================")
  end

  defp get_state(key) do
    Agent.get(__MODULE__, fn state -> state[key] end)
  end

  defp update_state(key, value) do
    Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
  end

  defp increase_count(key, count) do
    old_count = get_state(key)
    update_state(key, old_count + count)
  end
end
