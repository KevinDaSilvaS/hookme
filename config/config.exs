import Config

config :hookme, Hookme.Sender,
  schedule_interval: System.get_env("SCHEDULE_INTERVAL", "800")
                    |> String.to_integer(),
  reschedule_interval: System.get_env("RESCHEDULE_INTERVAL", "500")
                    |> String.to_integer(),
  max_retry: System.get_env("RETRY_MAX_ATTEMPTS", "3")
            |> String.to_integer(),
  webhook_url: System.get_env("WEBHOOK_URL", "")

config :hookme, Integrations.GithubApiIntegration,
  api_url: System.get_env("API_URL", "")
