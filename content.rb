class Shoes::Content < Shoes::Widget
  def initialize(opt={}, &block)
    flow :top => 0,:left => 200,:height => 600 do
      @image = image(opt[:path] || '' ,:weight => 600,:height => 600)
    end
  end

  def image=(args)
    @image.path = args
  end
end


# 3.times {|x| eval "@e#{x}.move(-10,-10) if @e#{x}"}
