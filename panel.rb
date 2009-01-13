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
        when "元素转换表" then
          content {ele_sub}
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


  def ele_sub
    #FIXME REMOVE
    config = YAML.load_file('config')

    table = File.exist?('element.csv') ? Table('element.csv') : []

    n,t,d = [],[],[]

    config.keys.each_with_index do |x,y|
      edit_line '', :width => 200,:state => 'disabled' if y == 0
      n[y] = edit_line :text => x, :width => 200,:state => 'disabled'
    end

    items = flow do
      table.size.times do |x|
        t[x]=[]
        d[x] = flow do
          (config.keys.size + 1).times do |y|
            t[x][y] = edit_line table[x] ? table[x][y] : '' , :width => 200
          end
          button "删除",:width => 100 do d[x].remove && t[x]=[] end
        end
      end
    end
    para "\n"

    tt    = []
    (config.keys.size + 1).times do |y|
      tt[y] = edit_line '' , :width => 200
    end

    button "添加",:width => 100 do
      items.append do
        size = t.size
        t[size] = []
        d[size] = flow do
          (config.keys.size + 1).times do |x|
            t[size][x] = edit_line tt[x].text, :width => 200
          end

          button "删除",:width => 100 do
            d[size].remove && t[t.size]=[]
          end
        end
      end
    end
    para "\n"*2

    button "保存",:width => 100 do
      File.open('element.csv','w+') do |x|
        x << ',' + n.map(&:text).join(',') + "\n"
        t.map do |y|
          x << y.map(&:text).join(',') + "\n" unless y.empty?
        end
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
