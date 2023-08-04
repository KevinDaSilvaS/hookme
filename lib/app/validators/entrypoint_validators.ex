defmodule App.Validators.EntrypointValidators do
  def sanitize_input(input), do: String.replace(input, "\n", "")

  def validate_proceed("Y"), do: true
  def validate_proceed("y"), do: true
  def validate_proceed(""), do: true
  def validate_proceed(_), do: false
end
