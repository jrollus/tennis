class ContactMailer < ApplicationMailer
  default from: '"Teqis Admin" <no-reply@teqis.club>'

  def contact_email(contact_message)
    @message = contact_message
    emails = ['rollus.jeremy@gmail.com', 'teqisclub@gmail.com']
    mail(to: emails, subject: @message.subject)
  end
end