defmodule Integrations.GithubApiIntegration do
  @config Application.compile_env(:hookme, Integrations.GithubApiIntegration)
  @api_url Keyword.get(@config, :api_url)
  @token Keyword.get(@config, :token)

  def headers() do
    ["Authorization": "Bearer #{@token}"]
  end

  def fetch_repo_data(username, repository) do
    [issues, contributors] = Task.await_many([
      Task.async(fn -> get_issues(username, repository) end),
      Task.async(fn -> get_contributors(username, repository) end)
    ])

    cond do
      issues == :error -> {:error, "error fetching issues"}
      contributors == :error -> {:error, "error fetching contributors"}
      true -> {:ok, %{
        user: username,
        repository: repository,
        issues: issues,
        contributors: contributors
      }}
    end
  end

  defp check_status_to_proceed(data) do
    case data.status_code do
      404 -> :skip
      _   -> Jason.decode!(data.body)
    end
  end

  defp data_expected_format(:skip), do: :skip
  defp data_expected_format(data) when is_map(data), do: :error
  defp data_expected_format(data), do: data

  defp get_issues(username, repository) do
    url = "#{@api_url}/repos/#{username}/#{repository}/issues"
    res = HTTPoison.get(url, headers())

    case res do
      {:ok, data} -> check_status_to_proceed(data)
        |> data_expected_format()
        |> map_issues()
      _ -> :error
    end
  end

  defp map_issues(:skip), do: %{error: "issues in repository not found"}
  defp map_issues(:error), do: :error
  defp map_issues(data) do
    Enum.map(data, fn issue ->
      title = Map.get(issue, "title")
      labels = Map.get(issue, "labels")
      author = Map.get(issue, "user", %{}) |> Map.get("login")
      %{title: title, labels: labels, author: author}
    end)
  end

  defp get_contributors(username, repository) do
    url = "#{@api_url}/repos/#{username}/#{repository}/contributors"
    res = HTTPoison.get(url, headers())

    case res do
      {:ok, data} -> check_status_to_proceed(data)
        |> data_expected_format()
        |> map_contributors()
      _ -> :error
    end
  end

  defp map_contributors(:skip), do: %{error: "contributors in repository not found"}
  defp map_contributors(:error), do: :error
  defp map_contributors(data) do
    Enum.map(data, fn contributor ->
      user = Map.get(contributor, "login")
      qtd_commits = Map.get(contributor, "contributions")
      name = Integrations.Users.get_user(user)
              |> manage_call(user)

      %{user: user, qtd_commits: qtd_commits, name: name}
    end)
  end

  defp manage_call(nil, user), do: get_name(user)
  defp manage_call(name, _user), do: {:ok, name}

  defp get_name(username) do
    url = "#{@api_url}/users/#{username}"
    res = HTTPoison.get(url, headers())
    case res do
      {:ok, data} ->
        name = Jason.decode!(data.body) |> Map.get("name")
        Integrations.Users.add_user(username, name)
        name
      _ -> :error
    end
  end

end
