# frozen_string_literal: true

require 'rmagick'
require 'fileutils'
# 323.8 is the value needed to get 1 inch tokens, accounting for issues with my pc's quirks
TOKEN_INCH_PIXELS = 328.8
PAGE_WIDTH = 2550  # 8.5 inches
PAGE_HEIGHT = 3300 # 11 inches
TOKEN_PADDING = 30 # Padding between tokens for cutting margins
TOKENS_PER_ROW = (PAGE_WIDTH / (TOKEN_INCH_PIXELS + TOKEN_PADDING)).floor
TOKENS_PER_COLUMN = (PAGE_HEIGHT / (TOKEN_INCH_PIXELS + TOKEN_PADDING)).floor

public

# Using an already made token with a border, create variants including numbers & bloodied/offline variants.
def create_token_set(token_path, asset_folder, dir_name)
  create_composites_handler(token_path, asset_folder, "/#{dir_name}")
end

# Create a basic token from an image and a border
def create_basic_token(image_path, border_path, dir_name)
  create_basic_token_handler(image_path, border_path, dir_name)
end

# Create a printable token sheet from a folder of tokens
def create_printable_token_sheet(input_path, output_filename, options = {})
  create_printable_sheet_handler(input_path, output_filename, options)
end

private

def create_basic_token_handler(path_to_image, path_to_border, dir_name)
  create_token_directory(root_path + dir_name)
  image = get_image_if_exists(path_to_image)
  border = get_image_if_exists(path_to_border)
  return unless image && border

  token = create_composite_image_for_basic_token(image, border)
  token_name = create_output_filename(path_to_image, dir_name)
  save_composite_image(token, token_name)
end

# If a folder is passed in, loop over the images in the folder and create composites of each one
# Otherwise just make the composites from the single image
def create_composites_handler(path_to_dir_or_image, asset_folder, dir_name)
  if input_is_directory(path_to_dir_or_image)
    create_composites_from_folder(path_to_dir_or_image, asset_folder, dir_name)
  else
    create_composites(path_to_dir_or_image, asset_folder, dir_name)
  end
end

def create_composites_from_folder(images_dir_path, asset_folder, output_dir_name)
  # first, create the output directory
  create_token_directory(root_path + output_dir_name)
  Dir["#{images_dir_path}/*.png"].each do |image|
    # within that directory, create the composites and put them into named folders
    create_composites(image, asset_folder, "#{output_dir_name}/#{File.basename(image, '.png')}")
  end
end

def create_composites(image_path, asset_folder, dir_name)
  base_image = get_image_if_exists(image_path)
  return unless base_image

  create_token_directory(root_path + dir_name)

  asset_names(asset_folder).each do |asset|
    asset_image = get_asset_image_and_resize(asset, base_image.columns, base_image.rows)
    # Composite the asset image onto the base image
    composited_image = create_composite_image(base_image, asset_image)
    # Save the composited image
    output_filename = create_output_filename_from_asset(asset, image_path, dir_name)
    save_composite_image(composited_image, output_filename)
  end
end

def get_asset_image_and_resize(asset, base_image_width, base_image_height)
  asset_image = get_image_if_exists(asset)
  if (base_image_width && base_image_height) && (base_image_width != 256 && base_image_height != 256)
    asset_image = resize_to_fit(asset_image, base_image_width,
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

def create_composite_image_for_basic_token(image, border)
  # Resize the larger image to fit within the smaller image dimensions
  resized_image = image.resize(256, 256)

  # Composite the images, centering the smaller image (border) on top of the larger image (resized_image)
  resized_image.composite(border, Magick::CenterGravity, Magick::OverCompositeOp)
end

# Resize while maintaining aspect ratio
def resize_to_fit(image, width, height)
  image.resize_to_fit(width, height)
end

# Resize ignoring aspect ratio
def resize(image, width, height)
  image.resize(width, height)
end

def create_output_filename_from_asset(asset, image_path, dir_name)
  File.join(root_path + dir_name, "#{File.basename(image_path, '.png')}_#{File.basename(asset, '.png')}.png")
end

def create_output_filename(image_path, dir_name)
  File.join(root_path + dir_name, "#{File.basename(image_path, '.png')}.png")
end

def create_token_directory(dir_name)
  Dir.mkdir(dir_name)
rescue Errno::EEXIST
  # Directory already exists, so no problem
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

def input_is_directory(input)
  Dir.exist?(input)
end

def create_printable_sheet_handler(input_path, output_filename, opts)
  # Create a new white canvas of letter size dimensions
  canvas = Magick::Image.new(PAGE_WIDTH, PAGE_HEIGHT) do |options|
    options.background_color = 'white'
  end
  canvas.x_resolution = 300
  canvas.y_resolution = 300
  canvas.units = Magick::PixelsPerInchResolution

  token_images = collect_token_images(input_path)
  return if token_images.empty?

  # Place each token on the canvas
  current_row = 0
  current_col = 0

  token_images.each do |token|
    # Calculate position for this token
    x = current_col * (TOKEN_INCH_PIXELS + TOKEN_PADDING) + TOKEN_PADDING
    y = current_row * (TOKEN_INCH_PIXELS + TOKEN_PADDING) + TOKEN_PADDING

    # Composite the token onto the canvas
    canvas = canvas.composite(token, x, y, Magick::OverCompositeOp)

    # Move to next position
    current_col += 1
    next unless current_col >= TOKENS_PER_ROW

    current_col = 0
    current_row += 1

    # If we've filled the page, save it and start a new one
    next unless current_row >= TOKENS_PER_COLUMN

    save_and_number_sheet(canvas, output_filename, opts[:save_to_directory])
    canvas = Magick::Image.new(PAGE_WIDTH, PAGE_HEIGHT) do |options|
      options.background_color = 'white'
    end
    current_row = 0
  end

  # Save the last sheet if it has any tokens
  return unless current_row.positive? || current_col.positive?

  save_and_number_sheet(canvas, output_filename, opts[:save_to_directory])
end

def collect_token_images(input_path)
  if input_is_directory(input_path)
    # Collect all PNG files from all subdirectories
    Dir.glob(File.join(input_path, '**', '*.png')).map do |file|
      image = get_image_if_exists(file)
      next unless image

      # Resize to exactly 1 inch (TOKEN_INCH_PIXELS x TOKEN_INCH_PIXELS pixels)
      image.resize(TOKEN_INCH_PIXELS, TOKEN_INCH_PIXELS)
    end.compact
  else
    # Single file case
    image = get_image_if_exists(input_path)
    return [] unless image

    [image.resize(TOKEN_INCH_PIXELS, TOKEN_INCH_PIXELS)]
  end
end

def save_and_number_sheet(canvas, output_filename, dir_name)
  # Create tokens directory if it doesn't exist
  file_path = root_path + dir_name
  create_token_directory(file_path)

  # If file exists, add a number to the filename
  base = File.basename(output_filename, '.*')
  ext = File.extname(output_filename)

  counter = 1
  final_filename = File.join(file_path, "#{base}#{ext}")

  while File.exist?(final_filename)
    final_filename = File.join(file_path, "#{base}_#{counter}#{ext}")
    counter += 1
  end

  canvas.units = Magick::PixelsPerInchResolution
  canvas.density = "#{TOKEN_INCH_PIXELS}x#{TOKEN_INCH_PIXELS}"
  canvas.write(final_filename)
  puts "Saved sheet: #{final_filename}."
end
