# frozen_string_literal: true

require_relative '../lib/token_maker'

# Thor command line interface for creating and managing game tokens
class CreateToken < Thor
  desc 'create_token_set FILE', 'create a group of tokens'
  method_option :count, type: :numeric, desc: 'Number of tokens to create (enables dynamic numbering)'
  method_option :include_special, type: :boolean, default: true, desc: 'Include special tokens (bloodied, offline)'
  def create_token_set(file)
    maker = TokenMaker.new(file)
    if options[:count]
      maker.create_game_token_set_with_dynamic_numbers(options[:count], options[:include_special])
    else
      maker.create_game_token_set
    end
  end
  desc 'create_token FILE FILE', 'create a single token using a border'
  def create_token(file, border)
    maker = TokenMaker.new(file, border)
    maker.create_game_token(file, border)
  end
  desc 'create_printable_sheet INPUT OUTPUT', 'create printable sheet(s) of tokens'
  method_option :save_to_directory, type: :string, default: '/printables', desc: 'Path to save directory'
  method_option :include_bloodied, type: :boolean, default: true, desc: 'Include bloodied variants'
  method_option :include_offline, type: :boolean, default: true, desc: 'Include offline variants'
  method_option :copies, type: :numeric, default: 1, desc: 'Number of copies of each token'
  def create_printable_sheet(input_path, output_filename)
    maker = TokenMaker.new(input_path)
    maker.create_printable_sheet(
      input_path,
      output_filename,
      {
        save_to_directory: options[:save_to_directory],
        include_bloodied: options[:include_bloodied],
        include_offline: options[:include_offline],
        copies: options[:copies]
      }
    )
  end
end
