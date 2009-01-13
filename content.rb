class Shoes::Content < Shoes::Widget
  def initialize(opt={}, &block)
  end

  def image=(args)
    @content.clear if @content
    return @image.path = args if @image
    @image = image(args,:weight => 600,:height => 600,:top => 0,:left => 200)
  end

  def content(&block)
    @image.path = '' if @image
    @content.clear if @content

    @content = flow(:top => 0,:left => 200,:height => 600) do
      yield if block
    end
  end
end


# 3.times {|x| eval "@e#{x}.move(-10,-10) if @e#{x}"}
