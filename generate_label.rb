require 'rqrcode' # https://github.com/whomwah/rqrcode.git
require 'barby' # https://github.com/toretore/barby.git
require 'barby/barcode/code_128'
require 'barby/barcode/qr_code'
require 'chunky_png' # https://github.com/wvanbergen/chunky_png.git
require 'barby/outputter/png_outputter'
require 'rmagick' # https://github.com/rmagick/rmagick.git

class LabelGenerator
  def initialize(qr_value, barcode_value, product_name, logo)
    @qr_value = qr_value
    @barcode_value = barcode_value
    @product_name = product_name
    @logo = logo
  end

  def generate
    img = create_image
    add_logo(img)
    add_qr_code(img)
    add_barcode(img)
    add_product_info(img)
    save_image(img)
  end

  private

  def create_image
    img = Magick::Image.new(800, 345)
    img.background_color = 'white'
    img
  end

def add_logo(img)
  logo = Magick::Image.read(@logo).first
  logo_png = logo.resize_to_fit!(120, 120)
  img.composite!(logo_png, 30, 10, Magick::OverCompositeOp)
end

  def add_qr_code(img)
    qr_code = RQRCode::QRCode.new(@qr_value)
    qr_png = qr_code.as_png(size: 340)
    qr_img = Magick::Image.from_blob(qr_png.to_s).first
    img.composite!(qr_img, 480, 15, Magick::OverCompositeOp)
  end

  def add_barcode(img)
    barcode = Barby::Code128B.new(@barcode_value)
    barcode_png = barcode.to_image(height: 40, margin: 0)
    barcode_img = Magick::Image.from_blob(barcode_png.to_s).first
    resize_barcode_img = barcode_img.resize_to_fit!(480, 420)
    img.composite!(resize_barcode_img, 30, 135, Magick::OverCompositeOp)
  end

  def add_product_info(img)
    draw = Magick::Draw.new
    draw.font = './font/Noto_Sans_JP/static/NotoSansJP-Regular.ttf'
    draw.pointsize = 24
    draw.text(180, 45, @product_name)
    draw.text(620, 330, @qr_value)
    draw.text(180, 330, @barcode_value)
    draw.draw(img)
  end

  def save_image(img)
    img.write("./output/#{@product_name}_label.png")
    puts "#{@product_name}_label.pngを生成しました。"
  end
end

qr_value = 'qrcode'
barcode_value = 'barcode'
product_name = 'product_name'
logo = './tuna.png'

LabelGenerator.new(qr_value, barcode_value, product_name, logo).generate
