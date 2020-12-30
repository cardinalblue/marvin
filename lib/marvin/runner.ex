defmodule Marvin.Runner do
  use DynamicSupervisor, restart: :transient
  alias Marvin.Worker
  alias Marvin.Reporter
  alias Marvin.HttpClient

  @type scenario :: %{
          concurrency: number(),
          endpoint: Marvin.HttpClient.endpoint()
        }

  def start_link(init_args) do
    DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def setup_workers(scenarios) do
    scenarios
    |> build_worker_specs()
    |> Task.async_stream(&DynamicSupervisor.start_child(__MODULE__, &1))
    |> Enum.to_list()
  end

  defp build_worker_specs(scenarios) do
    Enum.flat_map(scenarios, fn scenario ->
      Enum.map(1..scenario.concurrency, &build_worker_spec(&1, scenario))
    end)
  end

  defp build_worker_spec(id, scenario) do
    args = [
      id: "#{scenario.name}_#{id}" |> String.to_atom(),
      reporter: Reporter,
      endpoint: scenario.endpoint,
      http_client: HttpClient
    ]

    {Marvin.Worker, args}
  end

  def run_workers() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_id, pid, _, _} -> pid end)
    |> Task.async_stream(&Worker.run_loop/1)
    |> Stream.run()
  end

  @doc """
  When a supervisor shuts down, it terminates all children in the opposite order they are listed.
  The termination happens by sending a shutdown exit signal, via
     Process.exit(child_pid, :shutdown)
  and then awaiting for a time interval (defaults to 5000ms).
  The supervisor will abruptly terminates the child with reason :kill
  if the child process does not terminate in this interval.
  """
  def stop() do
    DynamicSupervisor.stop(__MODULE__, :shutdown)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def generate_random_id() do
    :rand.uniform(1_000_000)
    |> Integer.to_string()
    |> String.to_atom()
  end
end
