class RankingHistoryPolicy < ApplicationPolicy
  def update?
    true if user.admin

    @record.player = user.player
  end

  def edit?
    update?
  end

  class Scope < Scope
    def resolve
      scope.includes(:ranking).order(start_date: :desc).where(player_id: user.player.id).group_by(&:year)
    end
  end
end