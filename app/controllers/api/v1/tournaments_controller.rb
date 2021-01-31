class Api::V1::TournamentsController < Api::V1::BaseController
  def index
    if params[:club].present?
      query = CascadingDropdownsQuery.new(policy_scope(Tournament), params[:club], current_user.player, true)
      if params[:type] == 'club' && params[:club].present?
        @options_list = query.select_categories(params[:type])
      elsif params[:type] == 'category' && params[:category].present?
        @options_list = query.select_dates(params[:category], params[:type])
      else
        render json: { error: "The output type must be specified"} , status: :not_found
        return
      end
      @options_list.first.gsub!(/'\d+'/, '\0 selected') if @options_list.size == 1
      @options_list.unshift("<option value></option>")
      (@options_list.size == 1) ? (render json: { error: "Couldn't find #{params[:type].capitalize}"} , status: :not_found) : (render json: @options_list)
    else
      skip_policy_scope
      render json: { error: "The output type must be specified"} , status: :not_found
    end
  end
end