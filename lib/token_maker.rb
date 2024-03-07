require_relative 'token_functions'

class TokenMaker
  attr_reader :image, :assetfolder
  
  public
  def initialize(image, assetfolder='assets')
    @image = image
    @assetfolder = assetfolder
  end

  def showImage()
    return image
  end

  def showAssetFolder()
    return assetfolder
  end

  def createToken(dirname='tokens')
    create_token_set(image, assetfolder, dirname)
  end
end