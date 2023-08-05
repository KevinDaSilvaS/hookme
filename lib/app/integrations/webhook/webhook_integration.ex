defmodule Integrations.WebhookIntegration do
  @config Application.compile_env(:hookme, Integrations.WebhookIntegration)
  @webhook_url Keyword.get(@config, :webhook_url)

  def send_data_to_webhook(data) do
    res = HTTPoison.post(@webhook_url, Jason.encode!(data))
    res |> extract_data() |> check_status()
  end

  defp extract_data({:ok, res}), do: res
  defp extract_data({:error, _}), do: :error

  defp check_status(:error), do: :error
  defp check_status(res) do
    cond do
      res.status_code > 399 -> :error
      true -> :ok
    end
  end
end
