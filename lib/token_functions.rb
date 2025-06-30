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
def create_token_set(token_path, asset_folder, dir_name, options = {})
  create_composites_handler(token_path, asset_folder, "/#{dir_name}", options)
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
def create_composites_handler(path_to_dir_or_image, asset_folder, dir_name, options = {})
  if input_is_directory(path_to_dir_or_image)
    create_composites_from_folder(path_to_dir_or_image, asset_folder, dir_name, options)
  else
    create_composites(path_to_dir_or_image, asset_folder, dir_name, options)
  end
end

def create_composites_from_folder(images_dir_path, asset_folder, output_dir_name, options = {})
  # first, create the output directory
  create_token_directory(root_path + output_dir_name)
  Dir["#{images_dir_path}/*.png"].each do |image|
    # within that directory, create the composites and put them into named folders
    create_composites(image, asset_folder, "#{output_dir_name}/#{File.basename(image, '.png')}", options)
  end
end

def create_composites(image_path, asset_folder, dir_name, options = {})
  base_image = get_image_if_exists(image_path)
  return unless base_image

  create_token_directory(root_path + dir_name)

  if options[:use_dynamic_numbers] && options[:count]
    # Generate numbered tokens dynamically
    (0...options[:count]).each do |number|
      numbered_image = create_numbered_token(base_image, number)
      output_filename = create_output_filename_with_number(image_path, number, dir_name)
      save_composite_image(numbered_image, output_filename)
    end

    # Generate special tokens if assets exist
    create_special_tokens(base_image, image_path, dir_name) if options[:include_special_tokens]
  else
    # Original asset-based approach
    asset_names(asset_folder).each do |asset|
      asset_image = get_asset_image_and_resize(asset, base_image.columns, base_image.rows)
      # Composite the asset image onto the base image
      composited_image = create_composite_image(base_image, asset_image)
      # Save the composited image
      output_filename = create_output_filename_from_asset(asset, image_path, dir_name)
      save_composite_image(composited_image, output_filename)
    end
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

def create_output_filename_with_number(image_path, number, dir_name)
  File.join(root_path + dir_name, "#{File.basename(image_path, '.png')}_#{number}.png")
end

def create_numbered_token(base_image, number)
  # Create a copy of the base image to avoid modifying the original
  numbered_image = base_image.copy

  # Calculate circle dimensions based on image size (matching PNG assets)
  circle_diameter = (base_image.columns * 0.18).to_i # ~18% of image width
  circle_radius = circle_diameter / 2

  # Position circle in bottom-right with padding from edges
  # Additional offset to move up and left as requested
  padding = (base_image.columns * 0.08).to_i
  additional_offset = 30
  circle_center_x = base_image.columns - circle_radius - padding - additional_offset
  circle_center_y = base_image.rows - circle_radius - padding - additional_offset

  # Draw the circular background first
  gc = Magick::Draw.new
  gc.fill = 'white' # White background
  gc.stroke = 'black'
  gc.stroke_width = 4
  gc.circle(circle_center_x, circle_center_y,
            circle_center_x + circle_radius, circle_center_y)
  gc.draw(numbered_image)

  # Configure text drawing
  gc = Magick::Draw.new
  gc.font_family = 'Arial'
  gc.font_weight = Magick::BoldWeight
  gc.pointsize = calculate_font_size(base_image.columns)
  gc.fill = 'black'
  gc.stroke = 'none' # No stroke on text since circle provides contrast

  # Center text within the circle
  text_metrics = gc.get_type_metrics(number.to_s)
  text_x = circle_center_x - (text_metrics.width / 2)
  text_y = circle_center_y + (text_metrics.height / 4) # Adjust for baseline

  # Draw the number centered in the circle
  gc.annotate(numbered_image, 0, 0, text_x, text_y, number.to_s)

  numbered_image
end

def create_special_tokens(base_image, image_path, dir_name)
  special_assets = ['bloodied.png', 'offline.png'].map { |asset| File.join(assets_path, asset) }

  special_assets.each do |asset_path|
    next unless File.exist?(asset_path)

    asset_image = get_asset_image_and_resize(asset_path, base_image.columns, base_image.rows)
    composited_image = create_composite_image(base_image, asset_image)
    output_filename = create_output_filename_from_asset(asset_path, image_path, dir_name)
    save_composite_image(composited_image, output_filename)
  end
end

def calculate_font_size(image_width)
  # Scale font size based on image dimensions to match existing number overlays
  # Base font size for 256px wide image is 36 (larger and bolder)
  base_size = 36
  base_width = 256
  (base_size * image_width / base_width).to_i
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

  token_images = collect_token_images(input_path, opts)
  return if token_images.empty?

  # Place each token on the canvas
  current_row = 0
  current_col = 0

  token_images.each do |token|
    # Calculate position for this token
    x = current_col * (TOKEN_INCH_PIXELS + TOKEN_PADDING) + TOKEN_PADDING
    y = current_row * (TOKEN_INCH_PIXELS + TOKEN_PADDING) + TOKEN_PADDING

    # Composite the token onto the canvas
    canvas = canvas.composite(token[:image], x, y, Magick::OverCompositeOp)
    token[:image].destroy! # Release the token image from memory
    GC.start

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

def collect_token_images(input_path, opts)
  if input_is_directory(input_path)
    # Collect all PNG files from all subdirectories
    Dir.glob(File.join(input_path, '**', '*.png')).flat_map do |file|
      base_name = File.basename(file, '.png')

      # Skip special tokens if not included
      next if base_name.include?('bloodied') && !opts[:include_bloodied]
      next if base_name.include?('offline') && !opts[:include_offline]

      # Add the token the specified number of times
      opts[:copies].times.map do
        image = get_image_if_exists(file)
        next unless image

        {
          image: image.resize(TOKEN_INCH_PIXELS, TOKEN_INCH_PIXELS)
        }
      end
    end.compact
  else
    # Single file case
    opts[:copies].times.map do
      image = get_image_if_exists(input_path)
      return [] unless image

      {
        image: image.resize(TOKEN_INCH_PIXELS, TOKEN_INCH_PIXELS)
      }
    end
  end
end

def save_and_number_sheet(canvas, output_filename, dir_name)
  # Create tokens directory if it doesn't exist
  file_path = root_path + dir_name
  create_token_directory(file_path)

  # If file exists, add a number to the filename
  base = File.basename(output_filename, '.*')
  ext = File.extname(output_filename)
  ext = '.png' if ext.empty?

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
