class Shoes::Content < Shoes::Widget
  attr :oval_num

  def image=(args)
    @content.clear if @content
    return @image.path = args if @image
    @image = image(args,:weight => 600,:height => 600,:top => 0,:left => 200)
  end

  def content(&block)
    clear_all

    @content = flow(:top => 0,:left => 200,:height => 600) do
      yield if block
    end
  end

  def clear_all
    @image.path = '' if @image
    @content.clear if @content
    $oval_num.map {|x| x.remove } if $oval_num
  end
end
