class Shoes::Content < Shoes::Widget
  attr :oval_num

  def image=(args)
    clear_all
    return @image.path = args if @image
    @image = image(args,:weight => 600,:height => 600,:top => 0,:left => 200)
  end

  def content(&block)
    clear_all

    @content = flow(:top => 0,:left => 200,:height => 600) do
      yield if block
    end
  end

  def draw_oval(x,y)
    @oval_num = [] unless @oval_num
    $content.fill "#000"
    s = @oval_num.size
    @oval_num[s] = $content.oval :top => x,:left => y,:width => 5,:height => 5
    return @oval_num[s]
  end

  def clear_all
    @image.path = '' if @image
    @content.clear if @content
    @oval_num.map {|x| x.remove } if @oval_num
  end
end
