class ContactMailer < ApplicationMailer
  default from: '"Teqis Admin" <no-reply@teqis.club>'

  def contact_email(contact_message)
    @message = contact_message
    mail(to: 'rollus.jeremy@gmail.com', subject: @message.subject)
  end
end