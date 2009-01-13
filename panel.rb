CONFIG_PATH = "#{ENV['HOME']}/.phase_diagram"

class Shoes::Panel < Shoes::Widget

  def initialize(&block)
    button "新建" ,:width => 200,:top => 650 do
      new && init_operate && init_select
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
        when "元素转换表" then
          $current_item.show_element
        when "删除" then
          if confirm("确定删除?")
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

  def new
    $content.content()
    $sidebar.content do
      stack do
        para "名称:"
        name = edit_line :width => 200

        button '添加相图图片',:width => 200,:margin_top => 20 do
          @file = ask_open_file
          $content.image=(@file)
        end

        para "相图主要成分及对应点:",:margin_top => 20
        3.times do |x|
          eval <<-RUBY
           @text#{x} = edit_line(:width => 200 )

           button('位置',:width => 200) do
             click do |_z,_x,_y|
               @e#{x} ? @e#{x}.move(_x,_y) : (@e#{x}=$content.draw_oval(_x,_y))
             end
           end
          RUBY
        end

        button "保存",:width => 200,:margin_top => 20 do
          # Ensure Directory
          dir = File.join(CONFIG_PATH,name.text)
          # FIXME handel when exist
          Dir.mkdir(dir) unless File.exist?(dir)
          Dir.chdir(dir)

          element = {}
          3.times do |x|
            eval "element.merge!(@text#{x}.text => [@e#{x}.top,@e#{x}.left])"
          end

          # Save Configure
          File.open('config','w+') do |x|
            x.syswrite(element.to_yaml)
          end

          # Copy Image
          FileUtils.copy(@file,'image') if @file

          # refresh
          init_select
        end
      end
    end
  end
end
