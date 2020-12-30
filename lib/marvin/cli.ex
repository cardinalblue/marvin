defmodule Marvin.CLI do
  def main(file_path \\ []) do
    file_path
    |> File.read!()
    |> Marvin.Config.load()
    |> Marvin.run()
  end
end
