require_relative '../lib/token_maker'

# unless ARGV.length == 1
#   puts "Usage: ruby #{__FILE__} [base_image_name]"
#   exit
# end

if ARGV.length >= 1 #quickmode
  maker = TokenMaker.new(ARGV[0])
  maker.createToken()
else #slowmode
  puts "Welcome to the TokenMaker!"
  puts "This program takes an image of a token (eventually it will be able to make tokens) and creates numbered and alternative copies of the token."
  puts "These tokens can then be used in Tabletop roleplaying games!"
  puts "Please enter the path to your token image: "
  begin
    path = gets
    path = path.strip
    raise BlankInputError, "The image path cannot be blank." if path.empty?
  rescue BlankInputError => e
    puts e.message
    retry
  else
    maker = TokenMaker.new(path)
    maker.createToken()
  end
end

