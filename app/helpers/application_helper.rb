module ApplicationHelper
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end

  def search_box(title, options = {}, &block)
    block_to_partial('shared/search_box', options.merge(:title => title), &block)
  end

  def menu_box(title, options = {}, &block)
    block_to_partial('shared/menu_box', options.merge(:title => title), &block)
  end
  
  def ui_icon_click(icon, onclick)
    s = %{
      <div class="ui-state-default ui-corner-all icon" onclick="#{onclick}">
         <span class="ui-icon ui-icon-#{icon}" />
      </div>
    }.html_safe
  end

  def ui_icon_href(icon, href)
    s = %{
      <span class="ui-state-default ui-corner-all this">
        <a href="#{href}">
          <img class="ui-icon ui-icon-#{icon}" src="/assets/spacer.gif" />
        </a>
      </span>
    }.html_safe
  end

  def to_c(number)
      return "&nbsp;" if number.nil? || number == "" || number == "&nbsp;"
      number_with_precision(number, :precision => 2, :delimiter => '.', :separator => ',') + ' kn' 
  end

  def search_form(options = {})
    render(:partial => 'shared/search_form', :locals => options)
  end

  def search_query
    params[:q].force_encoding("utf-8") unless params[:q].nil?
  end
end

