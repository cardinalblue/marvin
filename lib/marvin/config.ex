defmodule Marvin.Config do
  alias Marvin.Config
  defstruct [:scenarios, :duration]

  def load(_input) do
    %Config{
      duration: 5,
      scenarios: [
        %{
          name: "yo",
          concurrency: 3,
          endpoint: {:get, "http://localhost:3000"}
        }
      ]
    }
  end
end
