class Shoes::Sidebar < Shoes::Widget

  def content(&block)
    @content.clear if @content
    @content = flow(:top => 0,:left => 0,:height => 600,:width => 200) do
      yield if block
    end
  end
end
