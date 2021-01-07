class Sidebar
  class Expander
    def self.setup
      new.setup
    end

    def setup
      on_toggle_sidebar
      on_expand_all
    end

    def on_toggle_sidebar
      menu = Element.find('#menu-toggle')
      menu.on(:click) do |e|
        e.prevent_default
        sidebar = Element.find("#sidebar")
        sidebar.toggle_class("toggled") # slide out sidebar menu
        menu.toggle_class("cross") # change hamburger to cross
      end
    end

    def on_expand_all
      expand_all = Element.find('#expand-all')
      @html = expand_all.html
      expand_all.on("click") do |e|
        @html = @html == "expand all" ? "collapse all" : "expand all"
        expand_all.html(@html)

        sidebar = Element.find("#sidebar")
        carets = sidebar.find("span.caret")
        carets.each do |caret|
          if @html == "expand all"
            expand_carret(caret)
          else
            collapse_carret(caret)
          end
        end
      end
    end

    def expand_carret(caret)
      caret.removeClass("caret-down")
      caret.siblings("ul").hide
    end

    def collapse_carret(caret)
      caret.addClass("caret-down")
      caret.siblings("ul").show
    end
  end
end