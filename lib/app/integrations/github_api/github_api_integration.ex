defmodule Integrations.GithubApiIntegration do
  @config Application.compile_env(:hookme, Integrations.GithubApiIntegration)
  @api_url Keyword.get(@config, :api_url)

  def fetch_repo_data(username, repository) do
    url = "#{@api_url}/repos/#{username}/#{repository}/issues"

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

  defp get_issues(username, repository) do
    url = "#{@api_url}/repos/#{username}/#{repository}/issues"
    res = HTTPoison.get(url)

    case res do
      {:ok, data} -> Jason.decode!(data.body) |> Enum.map(fn issue ->
        title = Map.get(issue, "title")
        labels = Map.get(issue, "labels")
        author = Map.get(issue, "user", %{}) |> Map.get("login")
        %{title: title, labels: labels, author: author}
      end)
      _ -> :error
    end
  end

  defp get_contributors(username, repository) do
    url = "#{@api_url}/repos/#{username}/#{repository}/contributors"
    res = HTTPoison.get(url)
    case res do
      {:ok, data} -> Jason.decode!(data.body) |> Enum.map(fn contributor ->
        user = Map.get(contributor, "login")
        qtd_commits = Map.get(contributor, "contributions")
        name = Integrations.Users.get_user(user)
                |> manage_call(user)

        %{user: user, qtd_commits: qtd_commits, name: name}
      end)
      _ -> :error
    end
  end

  defp manage_call(nil, user), do: get_name(user)
  defp manage_call(name, _user), do: {:ok, name}

  defp get_name(username) do
    url = "#{@api_url}/users/#{username}"
    res = HTTPoison.get(url)
    case res do
      {:ok, data} ->
        name = Jason.decode!(data.body) |> Map.get("name")
        Integrations.Users.add_user(username, name)
        name
      _ -> :error
    end
  end

end
