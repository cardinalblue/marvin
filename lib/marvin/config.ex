defmodule Marvin.Config do
  defstruct [:scenarios, :duration]

  def load(json_input) do
    json_input
    |> Jason.decode!()
    |> normalize
  end

  defp normalize(%{"duration" => duration, "scenarios" => scenarios}) do
    normalized_scenarios =
      scenarios
      |> Enum.map(fn %{"name" => name, "concurrency" => con, "endpoint" => endpoint} ->
        %{name: name, concurrency: con, endpoint: normalize_endpoint(endpoint)}
      end)

    %{duration: duration, scenarios: normalized_scenarios}
  end

  defp normalize_endpoint(endpoint) do
    case endpoint["method"] do
      "get" -> {:get, endpoint["url"]}
      "post" -> {:post, endpoint["url"], endpoint["body"]}
    end
  end
end
