class Api::V1::TournamentsController < Api::V1::BaseController
    def index
        if params[:club].present? || params[:category].present? || params[:type].present? || params[:ctype].present?
            player_age = Date.today.year - current_user.player.birthdate.year
            query = "tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max "
            if params[:type] == 'club'
                @tournaments = policy_scope(Tournament).includes(:category).joins(:category)
                               .where(query, params[:club], current_user.player.gender, params[:ctype], player_age, player_age)
                @options_list = @tournaments.map{ |tournament| generate_option_tag(tournament, params[:type]) }.uniq.sort_by {|category| category.scan(/'(\d+)'/)[0][0].to_i}
            elsif params[:type] == 'category'
                query += "AND tournaments.category_id = ?"
                @tournaments = policy_scope(Tournament).includes(:category).joins(:category)
                               .where(query, params[:club], current_user.player.gender, params[:ctype], player_age, player_age,params[:category])
                @options_list = @tournaments.map{ |tournament| generate_option_tag(tournament, params[:type]) }.uniq.sort_by {|category| category.scan(/'(\d+)'/)[0][0].to_i}
            end
            @options_list.unshift("<option value></option>")
            (@options_list.size == 1) ? (render json: { error: "Couldn't find #{params[:type].capitalize}"} , status: :not_found) : (render json: @options_list)
        else
            @tournaments = policy_scope(Tournament)
            @options_list = []
            @options_list << "<option value></option>"
            render json: { error: "The output type must be specified"} , status: :not_found
        end
    end

    private

    def generate_option_tag(tournament, type)
        if type == 'club'
            "<option value='#{tournament.category.id}'>#{tournament.category.category}</option>"
        elsif type == 'category'
            "<option value='#{tournament.id}'>#{tournament.start_date.strftime("%d/%m/%Y")} - #{tournament.end_date.strftime("%d/%m/%Y")}</option>"
        end
    end
end