# frozen_string_literal: true

require 'tk'
require_relative '../lib/token_maker'

root = TkRoot.new { title 'Token Machine' }

canvas = TkCanvas.new(root) do
  width 600
  height 400
  pack
end

static_image = TkPhotoImage.new(file: 'lib/assets/token_backgrounds/silver.png')

TkcImage.new(canvas, 0, 0, image: static_image, anchor: 'nw')

root.title = 'Window'

button_click = proc do
  path = Tk.getOpenFile
  maker = TokenMaker.new(path)
  maker.create_token
end

TkLabel.new(root) do
  text  'Select an RPG Token image to use'
  pack  do
    padx 15
    pady 15
    side 'left'
  end
end
button = TkButton.new(root) do
  text 'Select Image'
  pack('side' => 'left', 'padx' => '50', 'pady' => '50')
end

button.comman = button_click

Tk.mainloop
