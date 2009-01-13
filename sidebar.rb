class Shoes::Sidebar < Shoes::Widget
  def initialize
  end

  def content(&block)
    flow(:top => 0,:left => 0,:height => 600,:width => 200) do
      yield
    end
  end
end
