class EmailSubscribersWorker
  include Sidekiq::Worker

  def perform(recipient_id, from, message)
    recipient = User.find(recipient_id)
    email_data = EmailData.new(from, message)
    UserMailer.email_subscribers(recipient, email_data).deliver_now
  end

end