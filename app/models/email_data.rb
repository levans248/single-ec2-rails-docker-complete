class EmailData
  attr_reader :from, :message

  def initialize(from="Anonymous", message=nil)
    @from = from
    @message = message
  end
end