class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :faq ]

  def home
  end

  def faq
  end

end
