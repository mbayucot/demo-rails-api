class ProductPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.product_manager? || user.admin?
  end

  def update?
    user.product_manager? || user.admin?
  end

  def destroy?
    user.product_manager? || user.admin?
  end

  def submit_for_review?
    user.product_manager? || user.admin?
  end

  def approve?
    user.admin?
  end

  def reject?
    user.admin?
  end

  def archive?
    user.admin?
  end
end