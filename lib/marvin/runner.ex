defmodule Marvin.Runner do
  use Supervisor, restart: :transient
  alias Marvin.Worker
  alias Marvin.Reporter
  alias Marvin.HttpClient

  @type scenario :: %{
          concurrency: number(),
          endpoint: Marvin.HttpClient.endpoint()
        }

  def start_link(scenarios) do
    children =
      scenarios
      |> Enum.flat_map(fn scenario ->
        Enum.map(1..scenario.concurrency, fn i ->
          args = [
            id: "#{scenario.name}_#{i}" |> String.to_atom(),
            reporter: Reporter,
            endpoint: scenario.endpoint,
            http_client: HttpClient
          ]

          {Marvin.Worker, args}
        end)
      end)

    Supervisor.start_link(__MODULE__, children, name: __MODULE__)
  end

  def run_workers() do
    Supervisor.which_children(__MODULE__)
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
    Supervisor.stop(__MODULE__, :shutdown)
  end

  @impl true
  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end

  def generate_random_id() do
    :rand.uniform(1_000_000)
    |> Integer.to_string()
    |> String.to_atom()
  end
end
