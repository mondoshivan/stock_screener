class UsersController < Controller

  use AssetHandler
  helpers StockScreenerHelpers

  before do
    protected!
  end

  get '/' do
    slim :users
  end

  get '/user' do
    @user = User.first(id: params[:id].to_i)
    slim :user
  end

end
