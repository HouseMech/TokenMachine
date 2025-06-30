# frozen_string_literal: true

require 'token_maker'

RSpec.describe 'TokenFunctions' do # rubocop:disable Metrics/BlockLength
  let(:base_token_name) { 'testtoken.png' }
  let(:dir_path) { '/spec/dev/tokens' }
  let(:images_directory) { '/spec/support/test_images' }
  let(:maker) { TokenMaker.new(base_token_name, assets_path) }
  let(:base_image_name) { '/spec/support/test_images/base_image/funny_guy.png' }
  let(:border) { '/lib/assets/token_borders/silver.png' }

  after do
    FileUtils.rm_rf(base_path + dir_path)
  end

  describe 'Validations' do
    it 'has an image name' do
      expect(maker.show_image).to eql 'testtoken.png'
    end

    it 'can change asset folder' do
      expect(maker.show_asset_folder).to eql assets_path
    end

    it 'looks for a default folder called assets when no asset_folder is specified' do
      maker2 = TokenMaker.new(base_token_name)
      expect(maker2.show_asset_folder).to eql 'assets'
    end
  end
  describe 'Expectations' do
    it 'creates a directory and saves composited images' do
      maker.create_game_token_set(dir_path)
      expect(Dir.exist?(base_path + dir_path)).to be true
      expect(Dir.children(base_path + dir_path).count).to be > 0
    end

    it 'can use a folder as input' do
      maker2 = TokenMaker.new(base_path + images_directory, assets_path)
      maker2.create_game_token_set(dir_path)
      expect(Dir.exist?(base_path + dir_path)).to be true
      expect(Dir.children(base_path + dir_path)).to include('testtoken', 'testtoken2')
      expect(Dir.children("#{base_path}#{dir_path}/testtoken").count).to be > 0
      expect(Dir.children("#{base_path}#{dir_path}/testtoken2").count).to be > 0
    end

    it 'can make a single composited image' do
      maker.create_game_token(base_path + base_image_name, base_path + border, dir_path)
      expect(Dir.exist?(base_path + dir_path)).to be true
      expect(Dir.children(base_path + dir_path).count).to eq(1)
    end
  end

  describe 'Printable Sheet Creation' do
    let(:printable_dir) { '/spec/dev/printables' }
    let(:tokens_dir) { base_path + dir_path }

    before do
      maker.create_game_token_set(dir_path)
    end

    after do
      FileUtils.rm_rf(base_path + printable_dir)
    end

    it 'creates a printable sheet from token directory' do
      output_filename = 'test_sheet'
      options = {
        save_to_directory: printable_dir,
        copies: 1,
        include_bloodied: true,
        include_offline: true
      }
      maker.create_printable_sheet(tokens_dir, output_filename, options)

      expect(Dir.exist?(base_path + printable_dir)).to be true
      expect(File.exist?(File.join(base_path + printable_dir, 'test_sheet.png'))).to be true
    end

    it 'adds .png extension when output filename has no extension' do
      output_filename = 'sheet_no_ext'
      options = {
        save_to_directory: printable_dir,
        copies: 1,
        include_bloodied: true,
        include_offline: true
      }
      maker.create_printable_sheet(tokens_dir, output_filename, options)

      expect(File.exist?(File.join(base_path + printable_dir, 'sheet_no_ext.png'))).to be true
    end

    it 'handles existing files by numbering them' do
      output_filename = 'duplicate_sheet.png'
      options = {
        save_to_directory: printable_dir,
        copies: 1,
        include_bloodied: true,
        include_offline: true
      }

      maker.create_printable_sheet(tokens_dir, output_filename, options)
      maker.create_printable_sheet(tokens_dir, output_filename, options)

      expect(File.exist?(File.join(base_path + printable_dir, 'duplicate_sheet.png'))).to be true
      expect(File.exist?(File.join(base_path + printable_dir, 'duplicate_sheet_1.png'))).to be true
    end
  end
end
