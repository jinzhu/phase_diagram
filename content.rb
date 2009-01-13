class Shoes::Content < Shoes::Widget
  def initialize(opt={}, &block)
    stack :top => 0,:left => 200,:height => 600 do
      @image = image(opt[:path] || '', :top => 0,:weight => 600,:height => 600)
    end
  end

  def image=(args)
    @image.path = args
  end
end


# 3.times {|x| eval "@e#{x}.move(-10,-10) if @e#{x}"}
#
# @image.path = '' if @image
