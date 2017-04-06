class UploadsController < ApplicationController
  def index
    @documents = Upload.all
  end

  def new
    @document = Upload.new
  end

  def create
    @document = Upload.new(uploader_name: params[:uploader_name], document: params[:document])
    if @document.save
      flash[:success] = "The document was added!"
      redirect_to uploads_path
    else
      render :new
    end
  end

end