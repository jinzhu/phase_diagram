#! /usr/local/bin/shoes design.rb

class Pd
  attr :path

  def initialize(args)
    @name      = args
    @path      = File.join( CONFIG_PATH , args )
    @config    = YAML.load_file(File.join( @path ,'config'))
    Dir.chdir(@path)
    @table     = File.exist?('element.csv') ? Table('element.csv') : Table('')
    @elements  = @config.keys
  end

  def show
    # 更换图片
    $content.image = File.join(@path,'image')
    # 画出三个顶点
    @config.each_with_index do |x,index|
      $app.draw_oval(:num => index,:top => x[1][0],:left => x[1][1])
    end
    show_sidebar
  end

  def show_sidebar
    $sidebar.content do
      t = @elements + @table.column(@table.column_names[0])

      @it = []
      t.size.times do |x|
        $app.para "\n"
        $app.para $app.strong(t[x]) ,:stroke => "#f00"
        @it[x] = $app.edit_line :width => 100,:left => 100
      end
    end
  end

  def show_element
    show_sidebar

    $content.content do
      # 表格标题
      @config.keys.each_with_index do |x,y|
        $app.edit_line '摩尔替换率', :width => 150,:state => 'disabled' if y == 0
        $app.edit_line :text => x, :width => 150,:state => 'disabled'
      end

      # 表格内容，最后加入删除按钮,删除需要删除行内容，以及该行
      t,d = [],[]
      items = $content.flow do
        @table.size.times do |x|
          t[x]=[]
          d[x] = $content.flow do
            (@config.keys.size + 1).times do |y|
              t[x][y] = $content.edit_line  @table[x][y], :width => 150
            end
            $content.button "删除",:width => 100 do d[x].remove && t[x]=[] end
          end
        end
      end
      $app.para "\n"

      # 空白一行，用来向表单中添加内容
      tt    = []
      (@config.keys.size + 1).times do |y|
        tt[y] = $content.edit_line '' , :width => 150
      end

      $content.button "添加",:width => 100 do
        items.append do
          size = t.size
          t[size] = []
          d[size] = $content.flow do
            (@config.keys.size + 1).times do |x|
              t[size][x] = $content.edit_line tt[x].text, :width => 150
            end

            $content.button "删除",:width => 100 do
              d[size].remove && t[t.size]=[]
            end
          end
        end
      end
      $content.para "\n"*2

      # 保存内容为 csv 文件
      $content.button "保存",:width => 100 do
        File.open(File.join(@path,'element.csv'),'w+') do |x|
          x << ',' + @config.keys.join(',') + "\n"
          t.map do |y|
            x << y.map(&:text).join(',') + "\n" unless y.empty?
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
      $app.draw_oval(:num => index,:top => x[1][0],:left => x[1][1])
    end

    $sidebar.content do
      $app.stack do
        $app.para "名称:"
        name = $app.edit_line @name,:width => 200

        $app.button '添加相图图片',:width => 200,:margin_top => 20 do
          @file = $app.ask_open_file
          $content.image=(@file)
        end

        @text = []
        $app.para "相图主要成分及对应点:",:margin_top => 20
        @config.each_with_index do |obj,index|
          @text[index] = $app.edit_line(obj[0],:width => 200 )

          $app.button('位置',:width => 200) do
            $app.click do |_z,_x,_y|
              $app.draw_oval(:num => index,:left => _x,:top => _y)
            end
          end
        end

        $app.button "保存",:width => 200,:margin_top => 20 do
          Dir.chdir(@path)

          element = {}
          $oval_num.size.times do |x|
            top  = $oval_num[x].top  + $oval_num[x].height/2
            left = $oval_num[x].left + $oval_num[x].width/2
            element.merge!(@text[x].text => [top,left])
          end

          # Save Configure
          File.open(File.join(@path,'config'),'w+') do |x|
            x.syswrite(element.to_yaml)
          end

          # Copy Image
          FileUtils.copy(@file,'image') if @file

          @config    = YAML.load_file(File.join( @path ,'config'))
          @elements  = @config.keys
        end
      end
    end
  end
end
