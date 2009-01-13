CONFIG_PATH = "#{ENV['HOME']}/.phase_diagram"

class Shoes::Panel < Shoes::Widget
  def initialize(&block)
    flow :top => 650,:left => 20 do
      button "新建" ,:width => 200 do
        new
      end

      para "选择操作"
      items = ["相图","元素转换表","修改相图","化学成分","化学组成表","删除"]
      list_box :items => items,:width => 200 do |x|
        case x.text
        when "相图" then
          $current_item.show
        when "元素转换表" then
          $current_item.show_element
        when "删除" then
          if confirm("确定删除?")
            FileUtils.rm_rf(File.join(CONFIG_PATH,@current_item))
            _init_panel
          end
        end
      end

      @selected = list_box :width => 200,:items => Dir.entries(CONFIG_PATH).reject{|x| x =~ /\.+/} do |x|
        show(x.text)
      end
    end
  end



  def show(args)
    $current_item = Pd.new(args)
    $current_item.show
  end

  def new
    $sidebar.content do
      stack do
        para "名称:"
        name = edit_line :width => 200

        button '添加相图图片',:width => 200,:margin_top => 20 do
          @file = ask_open_file
          _init_content(@file)
        end

        para "相图主要成分及对应点:",:margin_top => 20
        3.times do |x|
          eval <<-RUBY
           @text#{x} = edit_line(:width => 200 )

           button('位置',:width => 200) do
             click do |_z,_x,_y|
               @e#{x} ? @e#{x}.move(_x,_y) : (@e#{x} = oval(_x,_y,5,5))
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

          3.times do |x|
            eval "element.merge!(@text#{x}.text => [@e#{x}.top,@e#{x}.left])"
          end

          # Save Configure
          File.open('config','w+') do |x|
            x.syswrite(element.to_yaml)
          end

          # Copy Image
          FileUtils.copy(@file,'image') if @file

          _init_panel
        end
      end
    end
  end
end
