require "sidebar/expander"

class Sidebar
  class << self
    def setup
      section = Element.find(".content-nav")
      urls = section.children("ul")
      urls.each do |ul|
        new(ul).setup
      end

      Expander.setup
    end
  end

  def initialize(el)
    @sidenav = el
  end

  def setup
    add_carets(@sidenav)
    on_toggle_caret
    init_carets
    expand_to_current
  end

  # Detects nested lists and only add carets as necessary
  #
  # before:
  #     <li><a>Docs</a></li>
  # after:
  #     <li><span class="caret caret-down"></span><a>Docs</a></li>
  #
  def add_carets(node)
    if node.tag_name == "li"
      if node.children("ul").size > 0
        node.prepend('<span class="caret caret-down"></span>')
      else
        node.prepend('<span class="caret caret-spacing"></span>')
      end
    end

    node.children.each do |child|
      add_carets(child)
    end
  end

  def on_toggle_caret
    @sidenav.on(:click) do |event|
      target = event.target
      caret = target.has_class?("caret-down") || target.has_class?("caret")
      if target.tag_name == "span" && caret
        target.toggleClass("caret-down")
        ul = target.siblings("ul")
        ul.toggle # hides or shows ul tag
      end
    end
  end

  # click on the all carets to initially close them
  def init_carets
    @sidenav.children.each do |child|
      next unless child.tag_name == "li"
      carets = child.find("span.caret")
      carets.click
    end
  end

  # Find current link associate with the currently viewed page,
  # then walk up the parents and show
  def expand_to_current
    current_location = $window.location.path # `window.location.pathname`

    # walk down tree
    links = @sidenav.find("a")
    current_link = links.select do |l|
      l.attr("href") == current_location
    end.first

    return unless current_link
    current_link.add_class("current-page")

    # walk back up tree starting with the sibling
    sibling = current_link.prev("span")
    sibling.click if sibling

    # walk back up rest of the tree
    uls = current_link.parents("ul")
    uls.each do |ul|
      span = ul.prevAll("span").first
      span.click if span
    end
  end
end
