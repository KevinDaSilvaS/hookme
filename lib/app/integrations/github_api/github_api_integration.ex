defmodule Integrations.GithubApiIntegration do
  @config Application.compile_env(:hookme, Integrations.GithubApiIntegration)
  @api_url Keyword.get(@config, :api_url)

  def fetch_repo_data(username, repository) do
    HTTPoison.get(@api_url)
  end
end
