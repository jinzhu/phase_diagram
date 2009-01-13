Shoes.setup do
  gem 'ruport'
end

$LOAD_PATH <<  File.dirname(__FILE__)

['ruport','yaml','symbol'].each {|x| require x}

class PhaseDiagram < Shoes

  url '/',     :index

  CONFIG_PATH = "#{ENV['HOME']}/.phase_diagram"
  Dir.mkdir(CONFIG_PATH) unless File.exist?(CONFIG_PATH)
  Dir.chdir(CONFIG_PATH)

  def index
    _init_main
  end

  def new
    _init_items
    _init_content

    element = { }
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

  def ele_sub
    #FIXME REMOVE
    config = YAML.load_file('config')

    table = File.exist?('element.csv') ? Table('element.csv') : []

    n,t,d = [],[],[]

    config.keys.each_with_index do |x,y|
      edit_line '', :width => 200,:state => 'disabled' if y == 0
      n[y] = edit_line :text => x, :width => 200,:state => 'disabled'
    end

    table.size.times do |x|
      t[x]=[]
      d[x] = flow do
        (config.keys.size + 1).times do |y|
          t[x][y] = edit_line table[x] ? table[x][y] : '' , :width => 200
        end
        button "delete" do d[x].remove && t[x]=[] end
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
    @current_item = args
    dir = File.join( CONFIG_PATH , args )
    Dir.chdir(dir)

      config = YAML.load_file('config')


      table = File.exist?('element.csv') ? Table('element.csv') : []

      t = config.keys.concat(table.column(table.column_names[0]))
      @it = []

      @items.clear do
        t.size.times do |x|
          para "\n",:height => 10
          para t[x],:left => 10
          @it[x] = edit_line :width => 100,:left => 100
        end
      end

      _init_content(File.join(dir,'image'))

      config.map do |x|
        oval :top => x[1][0],:left => x[1][1],:width => 5,:height => 5
      end
  end

  protected
  def _init_main
    _init_items
    _init_content
    _init_panel
  end

  def _init_items(&block)
    @items ? @items.clear(block) :
      @items = flow(:height => 400,:width => 200)
  end

  def _init_content(path = '')
    3.times {|x| eval "@e#{x}.move(-10,-10) if @e#{x}"}

    @image.path = '' if @image
    @image = image(path,:left =>210,:top =>10,:weight => 600,:height => 600)
  end

  def _init_panel
    flow :top => 350,:left => 50 do
      button "新建" ,:width => 200 do
        @items.clear { new }
      end

      para "选择操作"
      items = ["相图","元素转换表","修改相图","化学成分","化学组成表","删除"]
      list_box :items => items,:width => 200 do |x|
        case x.text
        when "元素转换表" then
          ele_sub
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
end

Shoes.app :width => 1000,:height => 800,:title => '相图分析'
