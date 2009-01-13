class Shoes::Sidebar < Shoes::Widget
  def initialize(&block)
    flow(:top => 0,:height => 600,:width => 200) do
      yield if block
    end
  end
end
