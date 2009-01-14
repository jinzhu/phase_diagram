#! /usr/local/bin/shoes design.rb

CONFIG_PATH = "#{ENV['HOME']}/.phase_diagram"

class Shoes::Panel < Shoes::Widget

  def initialize(&block)
    button "新建" ,:width => 200,:top => 650 do
      Pd.add && init_operate && init_select
    end
    init_operate && init_select
  end

  def init_operate
    @operate.clear if @operate

    items = ["相图","元素转换表","修改相图","化学成分","化学组成表","删除"]

    @operate = flow :top => 650,:left => 220 do
      para "选择操作"
      list_box :items => items,:width => 200,:left => 100 do |x|
        case x.text
        when "相图" then
          $current_item.show
        when "修改相图" then
          $current_item.edit
        when "元素转换表" then
          $current_item.show_element
        when "删除" then
          if confirm("确定删除?")
            #FIXME Add to pd file
            FileUtils.rm_rf($current_item.path)
            init_select
          end
        end
      end
    end
  end

  def init_select
    @selected.clear if @selected

    items = Dir.entries(CONFIG_PATH).reject{|x| x =~ /\.+/}

    @selected = flow :top => 650,:left => 540 do
      para "选择相图"
      list_box :width => 200,:items => items,:left => 100 do |x|
        show(x.text)
      end
    end
  end

  def show(args)
    $current_item = Pd.new(args)
    $current_item.show
  end
end
