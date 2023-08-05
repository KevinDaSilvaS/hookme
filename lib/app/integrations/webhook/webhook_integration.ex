defmodule Integrations.WebhookIntegration do
  @config Application.compile_env(:hookme, Integrations.WebhookIntegration)
  @webhook_url Keyword.get(@config, :webhook_url)

  def send_data_to_webhook(data) do
    HTTPoison.post(@webhook_url, Jason.encode!(data))
  end
end
