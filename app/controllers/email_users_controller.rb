class EmailUsersController < ApplicationController

  def new
  end

  def create
    recipients = User.all
    recipients.each do |recipient|
      EmailSubscribersWorker.perform_async(recipient.id, params[:from], params[:message])
    end
    flash[:email_sent] = "Thanks! Emails are being sent"
    redirect_to "/"
  end

end
