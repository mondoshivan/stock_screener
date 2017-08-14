

class AssetHandler < Controller
  configure do
    set :views, settings.root + '/assets'
    set :jsdir, 'js'
    set :cssdir, 'css'
    enable :coffeescript
    set :cssengine, 'scss'
  end

  get '/*.js' do
    pass unless settings.coffeescript?
    last_modified File.mtime(settings.root+'/assets/'+settings.jsdir)
    cache_control :public, :must_revalidate
    coffee (settings.jsdir + '/' + params[:splat].first).to_sym
  end

  get '/*.css' do
    last_modified File.mtime(settings.root + '/assets/' + settings.cssdir)
    cache_control :public, :must_revalidate
    send(settings.cssengine, (settings.cssdir + '/' + params[:splat].first).to_sym)
  end
end