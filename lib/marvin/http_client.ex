defmodule Marvin.HttpClient do
  alias Marvin.Config
  @default_headers [{"Content-Type", "application/json"}]
  @timeout_settings [pool_timeout: 20000, receive_timeout: 20000]

  @callback request(Config.endpoint()) :: :ok | {:error, [{atom, binary}, ...]}

  def child_spec do
    {Finch,
     name: __MODULE__,
     pools: %{
       # TODO: Make it configurable
       default: [size: 300]
     }}
  end

  @spec request(Config.endpoint()) :: :ok | {:error, [{atom, binary}, ...]}
  def request({:get, path}) do
    :get
    |> Finch.build(path, @default_headers)
    |> Finch.request(__MODULE__, @timeout_settings)
    |> format_response()
  end

  def request({:post, path, body}) do
    :post
    |> Finch.build(path, @default_headers, body)
    |> Finch.request(__MODULE__, @timeout_settings)
    |> format_response()
  end

  @spec format_response(
          {:error,
           %{
             :__exception__ => any,
             :__struct__ => Mint.HTTPError | Mint.TransportError,
             :reason => any,
             optional(:module) => any
           }}
          | {:ok, Finch.Response.t()}
        ) :: :ok | {:error, any}
  def format_response(response) do
    case response do
      {:ok, _} -> :ok
      {:error, e} -> {:error, [{e.__struct__, Exception.message(e)}]}
    end
  end
end
