class UserMailer < ApplicationMailer

  def email_subscribers(recipient, email_data)
    @recipient = recipient
    @from = email_data.from
    @message = email_data.message
    mail(to: @recipient.email, subject: "Rails School Example App Message")
  end
end
