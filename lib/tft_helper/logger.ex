defmodule TftHelper.Logger do
  @moduledoc false
  require Logger
  @log_file  "../../../logs/TFTHelper.log"

  def info_log(message) when is_bitstring(message) do
    if Mix.env() != "test" do
      @log_file |> Path.expand(__DIR__) |> File.write("[INFO][TFTHelper-#{Timex.now("America/Sao_Paulo") |> NaiveDateTime.truncate(:second)}] - #{message}\n", [:append])
    end
    Logger.info("[TFTHelper-#{Timex.now("America/Sao_Paulo") |> NaiveDateTime.truncate(:second)}] - #{message}")
    end

  def info_log(message) do
    info_log(inspect message)
  end

  def error_log(message) when is_bitstring(message) do
    if Mix.env() != "test" do
      @log_file |> Path.expand(__DIR__) |> File.write("[ERROR][TFTHelper-#{Timex.now("America/Sao_Paulo") |> NaiveDateTime.truncate(:second)}] - #{message}\n", [:append])
    end
    Logger.error("[TFTHelper-#{Timex.now("America/Sao_Paulo") |> NaiveDateTime.truncate(:second)}] - #{message}")
  end

  def error_log(message) do
    error_log(inspect message)
  end
end
