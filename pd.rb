#! /usr/local/bin/shoes design.rb

class Pd
  attr :path

  def initialize(args)
    @name      = args
    @path      = File.join( $config_path , args )
    Dir.chdir(@path)
    @table     = File.exist?('element.csv') ? Table('element.csv') : Table('')
    @config    = YAML.load_file(File.join( @path ,'config'))
  end

  def destory
    FileUtils.rm_rf(@path) && $panel.init_select if confirm("确定删除?")
  end

  def triangle
#                         -- A-0
#                        -  -
#                       -    -
#                      -      -
#                     -        -
#                    -          -
#                   -            -
#              B-1 ---------------- C-2


    p  = @config.values
    k  = @config.keys
    p0 = 0.5
    p1 = 0
    p2 = 1 - p0 - p1

    l01 = Math.sqrt((p[0][0]-p[1][0])**2 + (p[0][1]-p[1][1])**2)
    l12 = Math.sqrt((p[2][0]-p[1][0])**2 + (p[2][1]-p[1][1])**2)
    l02 = Math.sqrt((p[2][0]-p[0][0])**2 + (p[2][1]-p[0][1])**2)
    # 余弦定理，求出 角1 的余弦值
    c_a_1 = (l01**2 + l12**2 - l02**2)/(2*l01*l12)
    # 角1 的正弦值
    s_a_1 = Math.sqrt(1 - c_a_1**2)
    # 点 A/C 做对边角的高度
    h0 = l01*s_a_1
    h2 = l12*s_a_1

    # A/C 所占面积的高
    ph0 = h0*p0
    ph2 = h2*p2


#                         -- A-0
#                        -  -
#                       -    -
#                      -      -
#                     -        -
#                    -          -
#                   -            -
#              B-1 ---------------- C-2

    # 直线 AB / BC 的斜率,y 值全部取负
    k01 = Float(p[1][1]-p[0][1])/Float(p[1][0]-p[0][0]) #A_C
    # $app.line(0,c,1000.0,1000.0*k01+c)
    k12 = Float(p[2][1]-p[1][1])/Float(p[2][0]-p[1][0]) #A_B
    # $app.line(0,c,1000.0,1000.0*k12+c)


    t2 = Float(p[0][1]-p[1][1])/Float(p[0][0]-p[1][0])
    kk2= Math.cos(Math.atan(t2) - Math.acos(c_a_1))

    c_a_2 = (l02**2 + l12**2 - l01**2)/(2*l02*l12)
    t0 = Float(p[2][1]-p[1][1])/Float(p[2][0]-p[1][0])

    puts k[0],k[1],k[2]
    $app.line(p[2][0],p[2][1],p[1][0],p[1][1])

    kk0= Math.cos(Math.atan(t0))
    puts Math.acos(c_a_2)/Math::PI*180
    puts Math.atan(t0)/Math::PI*180
    
    c2 = p[1][1] - k01*p[1][0] + ph2/kk2
    c0 = p[1][1] - k12*p[1][0] + ph0/kk0

    # $app.line(0,c2,1000.0,1000.0*k01+c2)
    $app.line(0,c0,-1000.0,-1000.0*k12+c0)

    # k01*x + c2 = k12*x + c0
    x = (c0 - c2)/(k01-k12)
    y = k01*x + c2
    $app.draw_p(:top => y,:left => x)
  end

  def  show
    show_sidebar

    # 更换图片
    $content.image = File.join(@path,'image')
    triangle
    # 画出三个顶点
    @config.each_with_index do |x,index|
      $app.draw_oval(:num => index,:left => x[1][0],:top => x[1][1])
    end
  end

  def show_sidebar
    # 修改后刷新配置文件
    @path   = Dir.pwd
    @config = YAML.load_file(File.join(@path,'config'))

    $sidebar.content do
      t = @config.keys + @table.column(@table.column_names[0])

      #FIXME 计算
      @it = []
      t.size.times do |x|
        $app.para $app.strong(t[x]) ,:stroke => "#f00"
        @it[x] = $app.edit_line :width => 200
      end
    end
  end

  def show_element
    show_sidebar
    size = @config.keys.size

    $content.content do
      # 表格标题
      $app.edit_line '摩尔替换率', :width => 150,:state => 'disabled'
      @config.keys.map do |x|
        $app.edit_line :text => x, :width => 150,:state => 'disabled'
      end

      items = $content.flow

      # 表格内容,添加预定义成分表
      @table.map {|x| items.append { add_row(x) }}

      # 空白行，用来向表单中添加内容
      $app.flow do
        (size+1).times{ |y| $app.edit_line :width => 150 }

        $app.button "添加",:width => 100 do |x|
          arg = x.parent.children[0..3]
          items.append {add_row(arg.map(&:text))}
          arg.map {|x| x.text = ''}
        end
      end

      # 保存内容为 csv 文件
      $content.button "保存",:width => 100 do
        File.open(File.join(@path,'element.csv'),'w+') do |f|
          f << ',' + @config.keys.join(',') + "\n"
          items.children.map do |x|
            f << x.children[0..3].map(&:text).join(',') + "\n"
          end
        end
        # 更新边
        @table  = Table(File.join(@path,'element.csv'))
        show_sidebar
      end
    end
  end


  def edit
    $content.image = File.join(@path,'image')

    @config.each_with_index do |x,index|
      $app.draw_oval(:num => index,:left => x[1][0],:top => x[1][1])
    end

    self.class.sidebar(@name,@config.keys)
  end

  def self.add
    $content.content
    sidebar
  end

  def self.sidebar(oldname='',keys=false)
    $sidebar.content do
      $app.para "名称:"
      name = $app.edit_line oldname,:width => 200

      #FIXME 原来的相图更换后因为缓存不能刷新
      $app.button '添加相图图片',:width => 200,:margin_top => 20 do
        @file          = $app.ask_open_file
        $content.image = @file
      end

      @text = []
      $app.para "相图主要成分及对应点:",:margin_top => 20
      3.times do |x|
        @text[x] = $app.edit_line(keys ? keys[x]:'',:width => 200 )

        $app.button('位置',:width => 200) do
          $app.click do |_z,_x,_y|
            $app.draw_oval(:num => x,:left => _x,:top => _y)
          end
        end
      end

      $app.button "保存",:width => 200,:margin_top => 20 do

        dir    = File.join($config_path,name.text)
        olddir = File.join($config_path,oldname) if oldname

        # 错误检查,提供的成分定位点少于成分数量, 名字为空, 成分名称为空，名称已经存在并且不是正在修改相图
        if $oval_num.size < @text.size || name.text.empty? || @text.select{|x| x.text.empty?}.size > 0 || ( File.exist?(dir) && dir != olddir )

          if File.exist?(dir) && dir != olddir
            alert("已经存在该名称")
          else
            alert("请提供正确的名称，成分及成分定位点")
          end

        else
          if oldname.empty?
            # 如果为新建,新建后 olddir等于dir,可以继续更新
            FileUtils.mkdir_p(dir) && olddir = dir
          else
            # 如果修改更换名称则移动目录,修改olddir,以继续更新
            (FileUtils.mv(olddir,dir) if dir != olddir) && olddir = dir
          end

          Dir.chdir(dir)

          # 保存元素的位置
          element = {}
          $oval_num.size.times do |x|
            top  = $oval_num[x].top  + $oval_num[x].height/2
            left = $oval_num[x].left + $oval_num[x].width/2
            element.merge!(@text[x].text => [left,top])
          end

          # 保存配置文件
          File.open(File.join(dir,'config'),'w+') do |x|
            x.syswrite(element.to_yaml)
          end

          # 如果新增图片或者更换则复制
          FileUtils.copy(@file,'image') if @file

          # 新建、更换名称时刷新
          $panel.init_select unless oldname == name.text
        end
      end
    end
  end

  def add_row(args)
    return $app.flow do
      args.each { |x| $app.edit_line  x, :width => 150 }
      $app.button "删除",:width => 100 do |x| x.parent.remove end
    end
  end
end
