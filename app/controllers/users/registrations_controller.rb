# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    build_resource
    yield resource if block_given?

    resource.build_player.ranking_histories.build
    @year_nbr_dates = YearDatesService.get_year_nbr_dates
    respond_with resource
  end

  # POST /resource
  def create
    @year_nbr_dates = YearDatesService.get_year_nbr_dates
    super
  end

  # DELETE /avatar
  def delete_avatar
    current_user.avatar.purge
    redirect_to edit_user_registration_path
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    current_user.avatar.purge if account_update_params["avatar"].present?
    super
  end

  # DELETE /resource
  def destroy
    resource.player.update(user_id: nil)
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, 
      keys: [:avatar, :email, :password, :password_confirmation, :terms_of_service,
             player_attributes: [:first_name, :last_name, :affiliation_number, :club_id, :birthdate, :dominant_hand, :gender, 
                                ranking_histories_attributes: [:ranking_id, :year, :year_number, :start_date, :end_date, :validated]]
            ]
    )
  end

  #If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update,
     keys: [:avatar, :email, :password, :password_confirmation, 
            player_attributes: [:id, :first_name, :last_name, :affiliation_number, :club_id, :birthdate, :dominant_hand, :gender]
           ]
    )
  end

  def update_resource(resource, params)
    # Require current password if user is trying to change password.
    return super if params["password"]&.present?

    # Allows user to update registration information without password.
    resource.update_without_password(params.except("current_password"))
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
