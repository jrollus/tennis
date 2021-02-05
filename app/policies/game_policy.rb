class GamePolicy < ApplicationPolicy
  def destroy?
    return true if user.admin
    (set_game_player ? true : false)
  end

  def validate?
    return true if user.admin
    (set_game_player ? true : false)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def set_game_player
    Game.find(record.id).game_players.find{|player| player.player_id == user.player.id}
  end
end