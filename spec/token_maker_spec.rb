require 'rmagick'
require_relative '../token_functions'  # Adjust the path according to your project structure

RSpec.describe 'TokenFunctions' do
  let(:base_image_name) { 'testtoken.png' }
  let(:asset_folder_name) { 'Resources' }
  let(:assets) { ['number0.png', 'bloodied.png', 'deactivated.png'] }
  let(:dir_name) { File.basename(:base_image_name, '.png') }

  before do
    FileUtils.mkdir_p(asset_folder_name) unless Dir.exist?(asset_folder_name)
    FileUtils.touch(File.join(asset_folder_name, assets))
    FileUtils.touch(base_image_name)
  end

  after do
    FileUtils.rm_rf(dir_name)
    FileUtils.rm_rf(asset_folder_name)
    FileUtils.rm_f(base_image_name)
  end

  describe '#create_composites' do
    it 'creates a directory and saves composited images' do
      create_composites(base_image_name, asset_folder_name, assets, dir_name)

      expect(Dir.exist?(dir_name)).to be true
      assets.each_with_index do |asset, index|
        if asset.include? "number"
          expect(File.exist?(File.join(dir_name, "image_#{index}.png"))).to be true
        else
          expect(File.exist?(File.join(dir_name, "image_#{File.basename(asset, ".png")}.png"))).to be true
        end
      end
    end
  end

  describe '#create_token_directory' do
    it 'creates the specified directory if it does not exist' do
      create_token_directory(dir_name)
      expect(Dir.exist?(dir_name)).to be true
    end
  end

  describe '#check_image_exists' do
    it 'returns an image if it exists' do
      image = check_image_exists(base_image_name)
      expect(image).to be_a(Magick::Image)
    end

    it 'exits if the image does not exist' do
      expect { check_image_exists('nonexistent.png') }.to raise_error(SystemExit)
    end
  end
end
