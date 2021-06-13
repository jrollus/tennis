class ContactsController < ApplicationController
  skip_before_action :authenticate_user!
  
  def new
    @message = ContactMessage.new
    authorize @message
  end

  def create
    @message = ContactMessage.new contact_message_params
    authorize @message
    if @message.valid?
      ContactMailer.contact_email(@message).deliver_now
      redirect_to root_path
      flash[:notice] = "Votre message a bien été envoyé. Nous vous répondrons aussi vite que possible"
    else
      render :new
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :body)
  end

end