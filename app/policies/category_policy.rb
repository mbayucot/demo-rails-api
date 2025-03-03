class CategoryPolicy < ApplicationPolicy
  def index?
    true # Everyone can view categories
  end

  def show?
    true # Everyone can view a single category
  end

  def create?
    user.admin? # Only admin can create categories
  end

  def update?
    user.admin? # Only admin can update categories
  end

  def destroy?
    user.admin? # Only admin can delete categories
  end
end