class Api::V1::TournamentsController < Api::V1::BaseController
  def index
    if params[:club].present? || params[:category].present? || params[:type].present? || params[:ctype].present?
      query = CascadingDropdownsQuery.new(policy_scope(Tournament), params[:club], current_user.player, true)
      if params[:type] == 'club'
          @options_list = query.select_categories(params[:type])
      elsif params[:type] == 'category'
          @options_list = query.select_dates(params[:category], params[:type])
      end
      @options_list.first.gsub!(/'\d+'/, '\0 selected') if @options_list.size == 1
      @options_list.unshift("<option value></option>")
      (@options_list.size == 1) ? (render json: { error: "Couldn't find #{params[:type].capitalize}"} , status: :not_found) : (render json: @options_list)
    else
      @tournaments = policy_scope(Tournament)
      @options_list = []
      @options_list << "<option value></option>"
      render json: { error: "The output type must be specified"} , status: :not_found
    end
  end
end