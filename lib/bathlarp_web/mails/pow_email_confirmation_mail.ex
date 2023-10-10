defmodule BathLARPWeb.PowEmailConfirmationMail do
  @moduledoc """
  E-mail template for account confirmation e-mails.
  """
  use BathLARPWeb, :mail

  def email_confirmation(assigns) do
    %Pow.Phoenix.Mailer.Template{
      subject: "[BathLARP] Confirm your e-mail address",
      html: ~H"""
      <p>Hi,</p>

      <p>
        Someone, hopefully you, has used your e-mail address to sign up to the BathLARP website. If
        it was you, please click the link below (or copy and paste it into your browser) to confirm:
      </p>

      <p><a href="<%= @url %>"><%= @url %></a></p>

      <p>
        If it was not you, please disregard this e-mail, and we will remove your e-mail address from
        our systems within the next seven days.
      </p>

      <p>
        Kind regards,<br>
        The BathLARP committee
      </p>
      """,
      text: ~P"""
      Hi,

      Someone, hopefully you, has used your e-mail address to sign up to the BathLARP website. If
      it was you, please visit the address below to confirm:

      <%= @url %>

      If it was not you, please disregard this e-mail, and we will remove your e-mail address from
      our systems within the next seven days.

      Kind regards,
      The BathLARP committee
      """
    }
  end
end
