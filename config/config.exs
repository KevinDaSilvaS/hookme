import Config

config :hookme, Hookme.Sender,
  schedule_interval:
    System.get_env("SCHEDULE_INTERVAL", "10800")
    |> String.to_integer(),
  reschedule_interval:
    System.get_env("RESCHEDULE_INTERVAL", "1500")
    |> String.to_integer(),
  max_retry:
    System.get_env("RETRY_MAX_ATTEMPTS", "3")
    |> String.to_integer()

config :hookme, Integrations.GithubApiIntegration,
  api_url: System.get_env("API_URL", "https://api.github.com"),
  token: System.get_env("API_TOKEN", "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")

config :hookme, Integrations.WebhookIntegration,
  webhook_url: System.get_env("WEBHOOK_URL", "https://webhook.site/61a356f2-a04b-4b9b-b1cb-96668d4727d9")

config :hookme, Limiter.Limiter,
  rate_limit_max_simultaneous_jobs:
    System.get_env("RATE_LIMIT_MAX_SIMULTANEOUS_JOBS", "-1")
    |> String.to_integer()
