module GroupsHelper
  def is_active?(current, page_name)
    "active" if current == page_name 
  end
end
