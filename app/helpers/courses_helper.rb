module CoursesHelper
  def parse_page(page)
    return page.to_i if page.match(/^\d+$/)

    0
  end

  def previous_page(page)
    parsed_page = parse_page(page)

    (parsed_page - 1).negative? ? 0 : parsed_page - 1
  end

  def next_page(page)
    parsed_page = parse_page(page)
    parsed_page + 1
  end
end
