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

  def triangle(opt={})
    c = opt.keys    # 成分位置
    k = opt.values  # 成分含量
    sum = 0
    k.map  {|x| Float( sum+=x )}  # 成分的总摩尔量
    k.map! {|x| Float(  x/sum )}  # 成分占总成分的摩尔百分比
    p = []
    c.map { |x| p << @config[x] }

    #               -- 0
    #              -  -
    #             -    -
    #            -      -
    #           -        -
    #          -          -
    #         -            -
    #      1 ---------------- 2

    # 三角形三个边长的距离
    l01 = Math.sqrt((p[0][0]-p[1][0])**2 + (p[0][1]-p[1][1])**2)
    l12 = Math.sqrt((p[2][0]-p[1][0])**2 + (p[2][1]-p[1][1])**2)
    l02 = Math.sqrt((p[2][0]-p[0][0])**2 + (p[2][1]-p[0][1])**2)

    # 余弦定理，角 1 的余弦值
    c_a_1 = (l01**2 + l12**2 - l02**2)/(2*l01*l12)
    # 角 1 的正弦值
    s_a_1 = Math.sqrt(1 - c_a_1**2)

    # 以 0/2 为顶点的三角形的高
    h0 = l01*s_a_1
    h2 = l12*s_a_1

    # 成分 0/2 所占面积的高
    ph0 = h0*k[0]
    ph2 = h2*k[2]

    # 各边的斜率
    k01 = Float(p[1][1]-p[0][1])/Float(p[1][0]-p[0][0])
    k02 = Float(p[2][1]-p[0][1])/Float(p[2][0]-p[0][0])
    k12 = Float(p[2][1]-p[1][1])/Float(p[2][0]-p[1][0])

    # y = k*x + c
    # (p[1][1]-k01*p[1][0])求出物质位置通过的平行线的常数 c
    # ph2/Math.cos(Math.atan(k01)) 根据百分比求出偏移距离
    c0 = p[1][1] - k12*p[1][0] + ph0/Math.cos(Math.atan(k12))
    c2 = p[1][1] - k01*p[1][0] + ph2/Math.cos(Math.atan(k01))

    # k01*x + c2 = k12*x + c0
    x = (c0 - c2)/(k01-k12)
    y = k01*x + c2
    $app.draw_p(:top => y,:left => x)
  end

  def  show
    show_sidebar

    # 更换图片
    $content.image = File.join(@path,'image')

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
      t = @config.keys + @table.column(0)

      t.map do |x|
        $app.para $app.strong(x) ,:stroke => "#f00"
        $app.edit_line :width => 200
      end
      $app.button "计算",:width => 100 do |x|
        children = x.parent.children
        e = {}
        t.size.times do |y|
          result = convert(children[2*y].text, children[2*y+1].text)
          @config.keys.map do |k|
            e[k] ||= 0
            e[k] += ( result[k] || 0)
          end
        end
        e.values.any?{|x| x>0} ? triangle(e) : alert("请先填写有效数据")
      end
      $app.button "清空",:width => 100 do |x|
        $p_num.map {|x| x.remove } && $p_num = [] if $oval_num
      end
    end
  end

  def convert(name,num)
    return {name => num.to_f} if @config.keys.include?(name)

    result = {}
    index = @table.column(0).index{|x| x == name}
    @table.column_names.map do |x|
      result[x] = @table.column(x)[index].to_f * num.to_f if index && x
    end
    return result
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
