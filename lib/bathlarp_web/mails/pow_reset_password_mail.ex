defmodule BathLARPWeb.PowResetPasswordMail do
  @moduledoc """
  E-mail template for password reset e-mails.
  """
  use BathLARPWeb, :mail

  def reset_password(assigns) do
    %Pow.Phoenix.Mailer.Template{
      subject: "[BathLARP] Reset password request",
      html: ~H"""
      <h3>Hi,</h3>

      <p>
        Someone, hopefully you, has requested a password reset for your account on the BathLARP
        website. If it was you, please click the link below (or copy and paste it into your browser)
        to reset your password:
      </p>

      <p><a href="<%= @url %>"><%= @url %></a></p>

      <p>
        You can disregard this email if you didn't request a password reset.
      </p>

      <p>
        Kind regards,<br>
        The BathLARP committee
      </p>
      """,
      text: ~P"""
      Hi,

      Someone, hopefully you, has requested a password reset for your account on the BathLARP
      website. If it was you, please visit the address below to reset your password:

      <%= @url %>

      You can disregard this email if you didn't request a password reset.
      """
    }
  end
end
