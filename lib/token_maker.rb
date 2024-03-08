require_relative 'token_functions'

class TokenMaker
  attr_reader :image, :assetfolder

  def initialize(image, assetfolder = 'assets')
    @image = image
    @assetfolder = assetfolder
  end

  def show_image
    image
  end

  def show_asset_folder
    assetfolder
  end

  def create_token(dirname = 'tokens')
    create_token_set(image, assetfolder, dirname)
  end
end
