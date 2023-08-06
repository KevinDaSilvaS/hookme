defmodule Server.Validators.TaskValidators do
  def map_fields(data) do
    username = Map.get(data, "username")
    repository = Map.get(data, "repository")

    cond do
      is_nil(username) -> {:error, %{code: 400, error: "field username is required"}}
      is_nil(repository) -> {:error, %{code: 400, error: "field repository is required"}}
      true -> {:ok, %{username: username, repository: repository}}
    end
  end

  def validate_rate_limit() do
    case Limiter.Limiter.proceed_request?() do
      false -> {:error, %{code: 429, error: "max simultaneous jobs"}}
      _ -> {:ok, true}
    end
  end
end
