class PlayerPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end
  
  def stats?
    true
  end

  def update?
    true
  end

  def edit?
    update?
  end
end
