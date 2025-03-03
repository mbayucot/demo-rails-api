class ProductPolicy < ApplicationPolicy
  def index?
    true # Everyone can view products
  end

  def show?
    true # Everyone can view a single product
  end

  def create?
    user.product_manager? || user.admin? # Product managers & admins can create products
  end

  def update?
    user.product_manager? || user.admin? # Product managers & admins can update products
  end

  def destroy?
    user.product_manager? || user.admin? # Product managers & admins can delete products
  end
end