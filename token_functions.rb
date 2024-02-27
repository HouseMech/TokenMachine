require 'rmagick'
require 'fileutils'

def create_token_directory(dir_name)
  Dir.mkdir(dir_name) unless Dir.exist?(dir_name)
end

def create_composites(base_image_name, asset_folder_name, assets, dir_name)
  begin
    base_image = Magick::Image.read(base_image_name).first
  rescue
    puts "Could not open the base image: #{base_image_name}"
    exit
  end
  
  assets.each_with_index do |asset, index|
    asset_image = Magick::Image.read(asset_folder_name + "/" + asset).first
    
    # Composite the asset image onto the base image
    composited_image = base_image.composite(asset_image, Magick::CenterGravity, Magick::OverCompositeOp)
    
    # Save the composited image
     if asset.include? "number" 
      output_filename = File.join(dir_name, "#{File.basename(base_image_name, ".png")}_#{index}.png")
     else 
      output_filename = File.join(dir_name, "#{asset}.png")
     end
    composited_image.write(output_filename)
    puts "Saved: #{output_filename}"
  end

  puts "Finished creating token images."
end