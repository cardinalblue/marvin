defmodule Marvin.Worker do
  # Use transient mode so when supervisor shuts it down it would properly exit.
  use GenServer, restart: :transient
  require Logger

  @type state :: %{
          reporter: term,
          endpoint: Marvin.HttpClient.endpoint(),
          http_client: term,
          n_failed: number,
          n_successful: number
        }

  def child_spec(args) do
    %{
      id: args[:id],
      start: {__MODULE__, :start_link, [args]},
      type: :worker,
      restart: :transient,
      shutdown: 3000
    }
  end

  # -------------------------------------------------------------
  # Client
  # -------------------------------------------------------------

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @spec run_loop(atom | pid) :: any
  def run_loop(worker) do
    send(worker, :run_loop)
  end

  def get_stats(worker) do
    GenServer.call(worker, :get_stats)
  end

  # -------------------------------------------------------------
  # Server (callbacks)
  # -------------------------------------------------------------

  @impl true
  def init(id: id, reporter: reporter, endpoint: endpoint, http_client: http_client) do
    Process.flag(:trap_exit, true)
    Logger.info("Worker #{id} initiating")

    init_state = %{
      reporter: reporter,
      endpoint: endpoint,
      http_client: http_client,
      n_failed: 0,
      n_successful: 0
    }

    {:ok, init_state}
  end

  @doc """
  Make request to :endpoint with :http_client.
  Wait for 10 milliseconds and do it again.
  The reason for the short interval is to make room for the process to receive other signals,
  namely the :shutdown callback.
  """
  @impl true
  def handle_info(:run_loop, %{endpoint: endpoint, http_client: client} = state) do
    response = client.request(endpoint)

    # Log whether the response is successful or not
    new_state =
      case response do
        :ok ->
          IO.write(".")
          increase_count(state, :n_successful)

        {:error, msg} ->
          Logger.error(msg)
          increase_count(state, :n_failed)
      end

    Process.send_after(self(), :run_loop, 10)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_stats, _from, state) do
    resp = %{
      n_successful: state[:n_successful],
      n_failed: state[:n_failed]
    }

    {:reply, resp, state}
  end

  @impl true
  def terminate(reason, state) do
    IO.inspect(reason, label: "Worker terminating")

    state[:reporter].log_result(
      successful: state[:n_successful],
      failed: state[:n_failed]
    )
  end

  defp increase_count(state, key) do
    old_count = state[key]
    Map.put(state, key, old_count + 1)
  end
end
