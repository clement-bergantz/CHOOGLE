class EmailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.subject}"
    message.to = [ 'bergantz.clement@gmail.com' ]
  end
end