Admin.controllers :base do

  get :index, :map => "/" do
    render "base/index"
  end
  
  get :upload do
    render "base/upload"
  end
  
  post :import do
    users = JSON.parse(File.read(params[:event][:upload][:tempfile]))
    users.each do |user|
      Account.create_from_json(user)
    end
    flash[:notice] = 'Json was successfully imported.'
    redirect url(:base, :index)
  end
end
