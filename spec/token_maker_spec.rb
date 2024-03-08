require 'token_maker'

RSpec.describe 'TokenFunctions' do
  let(:base_image_name) { 'testtoken.png' }
  let(:dir_path) { '/spec/dev/tokens' }
  let(:maker) { TokenMaker.new(base_image_name, assets_path) }

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
      maker2 = TokenMaker.new(base_image_name)
      expect(maker2.show_asset_folder).to eql 'assets'
    end
  end
  describe 'Expectations' do
    it 'creates a directory and saves composited images' do
      maker.create_token(dir_path)
      expect(Dir.exist?(base_path + dir_path)).to be true
      expect(Dir.children(base_path + dir_path).count).to be > 0
    end
  end
end
