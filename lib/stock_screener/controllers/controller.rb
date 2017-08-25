

class Controller < Sinatra::Base

  register Sinatra::Flash
  register Sinatra::Auth

  configure do
    enable :sessions
    enable :method_override
    set :root, File.join(File.dirname(__FILE__), '../../../')
  end

  configure :development do
    register Sinatra::Reloader
    enable :reloader
    enable :logging
  end

  before do
    logger.info "[params] #{params.inspect}"
  end

end