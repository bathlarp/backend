defmodule BathLARPWeb.PowMailer do
  @moduledoc """
  Mailer for Pow; delegates to Swoosh for actually sending the mails.
  """
  use Pow.Phoenix.Mailer
  use Swoosh.Mailer, otp_app: :bathlarp

  import Swoosh.Email

  require Logger

  @impl true
  @spec cast(%{
          :html => nil | binary,
          :subject => binary,
          :text => nil | binary,
          :user => atom | %{:email => any, optional(any) => any},
          optional(any) => any
        }) :: Swoosh.Email.t()
  def cast(%{user: account, subject: subject, text: text, html: html}) do
    Logger.debug("building mail for #{account.email}")

    %Swoosh.Email{}
    |> to({"", account.email})
    |> from({"BathLARP", "no-reply@bathlarp.co.uk"})
    |> subject(subject)
    |> html_body(html)
    |> text_body(text)
  end

  @impl true
  @spec process(any) :: :ok
  def process(email) do
    Logger.debug("sending email")
    # Sending the e-mail async means that if we're sending a user confirmation e-mail, there's no
    # difference in execution time between a brand-new user and a user that already exists, thus
    # preventing timing-based enumeration attacks.
    Task.start(fn ->
      email
      |> deliver()
      |> log_warnings()
    end)

    :ok
  end

  defp log_warnings({:error, reason}),
    do: Logger.warning("Mailer backend failed with: #{inspect(reason)}")

  defp log_warnings({:ok, response}), do: {:ok, response}
end
