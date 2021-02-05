class GameFormPolicy < ApplicationPolicy
  def create?
    true
  end
  
  def new?
    create?
  end
  
  def update?
    return true if user.admin

    game_player = Game.find(record.game.id).game_players.find{|player| player.player_id == user.player.id}
    (game_player ? true : false)
  end

  def edit?
    update?
  end
end 