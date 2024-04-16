# frozen_string_literal: true

require 'rmagick'
require 'fileutils'

public

def create_token_set(image_path, asset_folder, dir_name)
  create_composites(image_path, asset_folder, "/#{dir_name}")
end

private

def create_composites(image_path, asset_folder, dir_name)
  base_image = get_image_if_exists(image_path)
  return unless base_image

  create_token_directory(root_path + dir_name)

  asset_names(asset_folder).each do |asset|
    asset_image = get_asset_image_and_resize(asset, base_image.columns, base_image.rows)
    # Composite the asset image onto the base image
    composited_image = create_composite_image(base_image, asset_image)
    # Save the composited image
    output_filename = create_output_filename(asset, image_path, dir_name)
    save_composite_image(composited_image, output_filename)
  end
end

def get_asset_image_and_resize(asset, base_image_width, base_image_height)
  asset_image = get_image_if_exists(asset)
  if (base_image_width && base_image_height) && (base_image_width != 256 && base_image_height != 256)
    asset_image = resize(asset_image, base_image_width,
                         base_image_height)
  end
  asset_image
end

def save_composite_image(composited_image, output_filename)
  composited_image.write(output_filename)
  puts "Saved: #{output_filename}"
end

def create_composite_image(image, asset_image)
  image.composite(asset_image, Magick::CenterGravity, Magick::OverCompositeOp)
end

def resize(image, width, height)
  image.resize_to_fit(width, height)
end

def create_output_filename(asset, image_path, dir_name)
  File.join(root_path + dir_name, "#{File.basename(image_path, '.png')}_#{File.basename(asset, '.png')}.png")
end

def create_token_directory(dir_name)
  Dir.mkdir(dir_name) unless Dir.exist?(dir_name)
end

def assets_path
  File.expand_path(File.join(root_path, 'lib', 'assets'))
end

def root_path
  File.expand_path(File.join(__dir__, '..'))
end

def asset_names(path_to_asset_folder)
  Dir["#{path_to_asset_folder == 'assets' ? assets_path : path_to_asset_folder}/*.png"]
end

def get_image_if_exists(image_path)
  begin
    base_image = Magick::Image.read(image_path).first
  rescue StandardError
    puts "Could not open the base image: #{image_path}"
    return nil
  end
  base_image
end
