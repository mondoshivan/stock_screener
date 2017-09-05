
class SearchController < Controller

  use AssetHandler
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
    enable :method_override

    set :hits, ['10','20','50','100']
    set :attribute_types, {
        :groth => {
            :name => 'Groth',
            :attributes => {
                :eps => {:name => 'EPS', :min => 0, :max => 100},
                :revenue => {:name => 'Revenue', :min => 0, :max => 100},
                :revenue_groth_rate => {:name => 'Revenue Groth Rate', :min => 0, :max => 100}
            }
        },
        :margins => {
            :name => 'Margins',
            :attributes => {
                :margin_ebitda => {:name => 'EBITDA Margin', :min => 0, :max => 100},
                :margin_gross => {:name => 'Gross Margin', :min => 0, :max => 100},
            }
        },
        :measures_of_size => {
            :name => 'Measures of Size',
            :attributes => {}
        }
    }
  end


  ###########
  # Helpers #
  ###########

  def table_page_selected?(page)
    return page == @current_page ? 'selected' : nil
  end

  def category_selected?(category)
    return category.id == params[:category].to_i ? 'selected' : nil
  end

  def exchange_selected?(exchange)
    return exchange.id == params[:exchange].to_i ? 'selected' : nil
  end

  def page_indicator_href(page)
    hash = request.env['rack.request.query_hash']
    hash['page'] = page
    uri = search_uri(hash)
    return uri
  end

  def hits_selected?(hits)
    return hits == params[:hits] ? 'selected' : nil
  end

  def find_attr_name(symbol)
    settings.attribute_types.each do |group_type, group_values|
      group_values[:attributes].each do |attribute_type, attr_values|
        if symbol == attribute_type
            return attr_values[:name]
        end
      end
    end
  end

  def get_param_attributes()
    attributes = {}
    params.each do |key, value|
      next unless key =~ /^attr_[a-zA-Z][a-zA-Z_]+[a-zA-Z]_(min|max){1}$/
      attr_type = key[('attr_'.length)..-5].downcase.to_sym # e.g. revenue, eps, ...
      attr_limit = key.split('_')[-1].downcase.to_sym       # e.g. min or max

      attributes[attr_type] = {:min => 0, :max => 0} unless attributes.keys.include?(attr_type)
      attributes[attr_type][attr_limit] = get_number_from_string(value)
      attributes[attr_type][:name] = find_attr_name(attr_type)
    end
    return attributes
  end

  ##################
  # Route Handlers #
  ##################

  get '/' do
    @attributes = get_param_attributes()

    hitsPerPage = params[:hits]
    @current_page = params[:page] ? params[:page].to_i : 1
    unfiltered = security_includes?(params[:search], :filter => {
        :exchange => params[:exchange],
        :category => params[:category]
    })
    @total = unfiltered.size
    @th = TableHandler.new(@total, hitsPerPage)
    range = @th.range_for_page(@current_page)
    @securities = unfiltered[range]
    @indicators = @th.indicators(@current_page)

    slim :search
  end

  get '/tickers' do
    content_type :json

    tickers = []
    Ticker.all(
        :name.like => "%#{params[:input]}%",
        :fields => [:name],
        :order => [ :name.asc ]
    ).each { |ticker| tickers << ticker.name }

    return tickers.to_json
  end

  get '/attributes' do
    return settings.attribute_types.to_json
  end

end
