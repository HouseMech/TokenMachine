require_relative 'token_functions'

# Check if the correct number of arguments is passed
unless ARGV.length == 1
  puts "Usage: ruby #{__FILE__} [base_image_name]"
  exit
end

base_image_name = ARGV[0]
asset_folder_name = "Resources"
assets = ['number0.png', 'number1.png', 'number2.png', 'number3.png', 'number4.png',
          'number5.png', 'number6.png', 'number7.png', 'number8.png', 'number9.png',
          'bloodied.png', 'deactivated.png']

# Create the directory
dir_name = "#{base_image_name}"

create_composites(base_image_name, asset_folder_name, assets, dir_name)

