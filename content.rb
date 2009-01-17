#! /usr/local/bin/shoes design.rb

class Shoes::Content < Shoes::Widget
  attr :oval_num

  def image=(args)
    clear_all
    @image = image(args,:weight => 600,:height => 600,:top => 0,:left => 220)
  end

  def content(&block)
    clear_all
    @content = flow(:top => 0,:left => 220,:height => 600) do
      yield if block
    end
  end

  def clear_all
    $app.click  # 清除单击

    [$oval_num,@image,@content,$p_num,$rt,$notice].map do |x|
      x.is_a?(Array) ? (x.map {|y| y.remove } && x = []) : (x.remove if x)
    end
  end
end
