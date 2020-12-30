defmodule Marvin.WorkerTest do
  use ExUnit.Case
  alias Marvin.Worker

  defmodule FakeReporter do
    def log(_data) do
      :ok
    end
  end

  defmodule FakeSuccessfulHttpClient do
    def request(_endpoint) do
      :ok
    end
  end

  defmodule FakeFailedHttpClient do
    def request(_endpoint) do
      {:error, reason: :yo}
    end
  end

  describe "run_loop/1" do
    test "increase n_successful when request returns :ok" do
      worker = setup_worker()

      send(worker, :run_loop)

      result_stats = Worker.get_stats(worker)
      assert result_stats == %{n_successful: 1, n_failed: 0}
    end

    test "increase n_failed when request returns :error" do
      worker = setup_worker(http_client: FakeFailedHttpClient)

      send(worker, :run_loop)

      result_stats = Worker.get_stats(worker)
      assert result_stats == %{n_successful: 0, n_failed: 1}
    end
  end

  describe "terminate/2 (callback)" do
    test "sends successful_count and failed_count to reporter" do
      worker = setup_worker(%{reporter: FakeReporter})

      Process.exit(worker, :shutdown)
    end
  end

  defp setup_worker(args \\ %{}) do
    start_supervised!(
      {Worker,
       [
         reporter: args[:reporter] || FakeReporter,
         endpoint: args[:endpoint] || {:get, "https://test-endpoint.com"},
         http_client: args[:http_client] || FakeSuccessfulHttpClient
       ]}
    )
  end
end
