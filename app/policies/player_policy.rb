class PlayerPolicy < ApplicationPolicy
  def show?
    true
  end

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

  def stats?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
