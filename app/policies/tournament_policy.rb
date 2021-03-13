class TournamentPolicy < ApplicationPolicy
  def create?
    true
  end
  
  def new?
    create?
  end

  def update?
    user.admin
  end

  def edit?
    update?
  end

  def validate?
    user.admin
  end
  
  def validations?
    user.admin
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
end