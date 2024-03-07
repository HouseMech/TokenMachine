require 'rmagick'
require 'fileutils'

class BlankInputError < StandardError;
end

public
def create_token_set(image_path, asset_folder, dir_name)
  create_composites(image_path, asset_folder, dir_name)
end

private
def create_composites(image_path, asset_folder_name, dir_name)
  dir_name = File.basename(dir_name, ".png")
  base_image = check_image_exists(image_path)
  create_token_directory(dir_name)
  
  get_asset_names().each_with_index do |asset, index|
    asset_image = Magick::Image.read(asset).first
    
    # Composite the asset image onto the base image
    composited_image = base_image.composite(asset_image, Magick::CenterGravity, Magick::OverCompositeOp)
    
    # Save the composited image
     if asset.include? "number" 
      output_filename = File.join(dir_name, "#{File.basename(image_path, ".png")}_#{index}.png")
     else 
      output_filename = File.join(dir_name, "#{File.basename(image_path, ".png")}_#{File.basename(asset, ".png")}.png")
     end
    composited_image.write(output_filename)
    puts "Saved: #{output_filename}"
  end

  puts "Finished creating token images."
end

def create_token_directory(dir_name)
  Dir.mkdir(dir_name) unless Dir.exist?(dir_name)
end

def get_asset_names()
  return Dir["../lib/assets/*.png"]
end

def check_image_exists(image_path)
  begin
    base_image = Magick::Image.read(image_path).first
  rescue
    puts "Could not open the base image: #{image_path}"
    exit
  end
  return base_image
end
