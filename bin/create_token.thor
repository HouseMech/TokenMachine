require_relative '../lib/token_maker'

class CreateToken < Thor
  desc 'create_token_set FILE', 'create a group of tokens'
  def create_game_token_set(file)
    maker = TokenMaker.new(file)
    maker.create_game_token_set
  end
  desc 'create_token FILE FILE', 'create a single token using a border'
  def create_token(file, border)
    maker = TokenMaker.new(file, border)
    maker.create_token(file,border)
  end
end
