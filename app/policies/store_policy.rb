class StorePolicy < ApplicationPolicy
  def index?
    true # Everyone can view stores
  end

  def show?
    true # Everyone can view a single store
  end

  def create?
    user.admin? # Only admin can create stores
  end

  def update?
    user.admin? # Only admin can update stores
  end

  def destroy?
    user.admin? # Only admin can delete stores
  end
end