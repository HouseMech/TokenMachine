require_relative '../lib/token_maker'

class CreateToken < Thor
  desc 'create_token_set FILE', 'create a group of tokens'
  def create_token_set(file)
    maker = TokenMaker.new(file)
    maker.create_game_token_set
  end
  desc 'create_token FILE FILE', 'create a single token using a border'
  def create_token(file, border)
    maker = TokenMaker.new(file, border)
    maker.create_game_token(file,border)
  end
  desc 'create_printable_sheet INPUT OUTPUT', 'create printable sheet(s) of tokens (1 inch each at 300 DPI)'
  def create_printable_sheet(input_path, output_filename = 'printable_sheet.png')
    maker = TokenMaker.new(input_path)
    maker.create_printable_sheet(input_path, output_filename)
  end
end
