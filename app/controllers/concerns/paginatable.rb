# app/controllers/concerns/paginatable.rb
module Paginatable
  extend ActiveSupport::Concern

  private

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page.presence,
      prev_page: collection.previous_page.presence,
      total_pages: collection.total_pages,
      total_entries: collection.total_entries
    }
  end
end