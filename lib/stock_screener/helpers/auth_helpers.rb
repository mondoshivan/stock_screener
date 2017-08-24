

module Sinatra
  module Auth
    module Helpers
      def authorized?
        session[:admin]
      end

      def logged_in?
        session[:logged_in]
      end

      def protected!
        halt 401,slim(:unauthorized) unless authorized?
      end

      def logged_in!
        halt 401,slim(:unauthorized) unless logged_in?
      end
    end

    def self.registered(app)
      app.helpers Helpers

      app.enable :sessions

      app.post '/login' do
        @user = User.first(name: params[:username], password: params[:password])
        if @user
          session[:admin] = @user.admin
          session[:logged_in] = true
          flash[:notice] = "You are now logged in as #{@user.name}"
          redirect to('/')
        else
          flash[:notice] = "The username or password you entered are incorrect"
          redirect to('/login')
        end
      end

      app.get '/logout' do
        session.clear
        flash[:notice] = "You have now logged out"
        redirect to('/')
      end
    end
  end
  register Auth
end