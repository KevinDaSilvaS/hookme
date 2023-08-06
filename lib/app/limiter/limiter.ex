defmodule Limiter.Limiter do
  @config Application.compile_env(:hookme, Limiter.Limiter)
  @rate_limit Keyword.get(@config, :rate_limit_max_simultaneous_jobs)

  def proceed_request?() do
    set_limit = rate_limit_is_set?()
    limit_reached = reached_limit?()
    cond do
      set_limit && limit_reached -> false
      true -> true
    end
  end

  defp rate_limit_is_set?() do
    cond do
      @rate_limit > 0 -> true
      true -> false
    end
  end

  defp reached_limit?() do
    Hookme.Keeper.get_tasks()
          |> Map.keys()
          |> Enum.count()
          |> fn size -> size >= @rate_limit end.()
  end
end
