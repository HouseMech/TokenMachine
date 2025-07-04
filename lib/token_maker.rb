# frozen_string_literal: true

require_relative 'token_functions'

# Creates tokens using the token_functions.rb file
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

  # Creates tokens with extra addons, adding identifying numbers and a bloodied/offline variant.
  # Use this with an existing token
  def create_game_token_set(dirname = 'tokens')
    create_token_set(image, assetfolder, dirname)
  end

  # Creates tokens with dynamic numbering instead of using PNG assets
  def create_game_token_set_with_dynamic_numbers(count, include_special = true, dirname = 'tokens')
    options = {
      use_dynamic_numbers: true,
      count: count,
      include_special_tokens: include_special
    }
    create_token_set(image, assetfolder, dirname, options)
  end

  # Creates a basic token for use with a TTRPG, compositing a chosen image with one of the border asset files.
  def create_game_token(image, border, dirname = 'tokens')
    create_basic_token(image, border, dirname)
  end

  def create_printable_sheet(
    input_path,
    output_filename = 'printable_sheet.png',
    options = {}
  )
    create_printable_token_sheet(
      input_path,
      output_filename,
      options
    )
  end
end
