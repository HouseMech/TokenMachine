require_relative '../lib/token_maker'

# unless ARGV.length == 1
#   puts "Usage: ruby #{__FILE__} [base_image_name]"
#   exit
# end

class BlankInputError < StandardError
end

if ARGV.length >= 1 # quickmode
  maker = TokenMaker.new(ARGV[0])
  if ARGV[1] && ARGV[1].match?(/^\d+$/)
    # Second argument is a number, use dynamic numbering
    count = ARGV[1].to_i
    maker.create_game_token_set_with_dynamic_numbers(count)
  else
    maker.create_game_token_set
  end
else # slowmode
  puts 'Welcome to the TokenMaker!'
  puts 'This program takes an image of a token and creates numbered and alternative copies of the token.'
  puts 'These tokens can then be used in Tabletop roleplaying games!'
  puts 'Please enter the path to your token image: '
  begin
    path = gets
    raise BlankInputError, 'The image path cannot be blank.' if path.nil? || path.to_s.strip.empty?
  rescue BlankInputError => e
    puts e.message
    retry
  else
    puts 'Enter number of tokens to create (leave blank for default 0-9 + special): '
    count_input = gets.strip
    maker = TokenMaker.new(path)
    if count_input.empty?
      maker.create_game_token_set
    else
      count = count_input.to_i
      maker.create_game_token_set_with_dynamic_numbers(count)
    end
  end
end
