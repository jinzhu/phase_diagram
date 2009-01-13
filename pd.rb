class Pd
  def initialize(args)
    @path      = File.join( CONFIG_PATH , args )
    @config    = YAML.load_file(File.join( @path ,'config'))
    Dir.chdir(@path)
    @table     = File.exist?('element.csv') ? Table('element.csv') : []
    @elements  = @config.keys
  end

  def show
    Dir.chdir(@path)
    # 更换图片
    $content.image = 'image'
    # 画出三个顶点
    @config.map do |x|
      $content.fill "#000"
      $content.oval :top => x[1][0],:left => x[1][1],:width => 5,:height => 5
    end
    show_sidebar
  end

  def show_element
    $content.content do
      n,t,d = [],[],[]

      @config.keys.each_with_index do |x,y|
        $app.edit_line '', :width => 150,:state => 'disabled' if y == 0
        n[y] = $app.edit_line :text => x, :width => 150,:state => 'disabled'
      end

      items = $content.flow do
        @table.size.times do |x|
          t[x]=[]
          d[x] = $content.flow do
            (@config.keys.size + 1).times do |y|
              t[x][y] = $content.edit_line @table[x] ? @table[x][y] : '' , :width => 150
            end
            $content.button "删除",:width => 100 do d[x].remove && t[x]=[] end
          end
        end
      end
      $app.para "\n"

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
              t[size][x] = edit_line tt[x].text, :width => 150
            end

            $content.button "删除",:width => 100 do
              d[size].remove && t[t.size]=[]
            end
          end
        end
      end
      $content.para "\n"*2

      $content.button "保存",:width => 100 do
        File.open('element.csv','w+') do |x|
          x << ',' + n.map(&:text).join(',') + "\n"
          t.map do |y|
            x << y.map(&:text).join(',') + "\n" unless y.empty?
          end
        end
      end
    end
  end

  def show_sidebar
    $sidebar.content do
      t = @elements.concat(@table.column(@table.column_names[0]))

      @it = []
      t.size.times do |x|
        $app.para "\n"
        $app.para $app.strong(t[x]) ,:stroke => "#f00"
        @it[x] = $app.edit_line :width => 100,:left => 100
      end
    end
  end
end
