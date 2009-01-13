class Shoes::Content < Shoes::Widget
  def initialize(opt={}, &block)
    @image = image(opt[:path] || '' ,:weight => 600,:height => 600,:top => 0,:left => 200)
  end

  def image=(args)
    @image.path = args
  end
end


# 3.times {|x| eval "@e#{x}.move(-10,-10) if @e#{x}"}
