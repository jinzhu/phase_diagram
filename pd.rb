class Pd
  attr :path,:config

  def initialize(args)
    @path   = File.join( CONFIG_PATH , args )
    @config = YAML.load_file(File.join( path ,'config'))
  end

  def show
    Dir.chdir(@path)
    $content.image = 'image'

    $sidebar.content do
      table = File.exist?('element.csv') ? Table('element.csv') : []

      t = @config.keys.concat(table.column(table.column_names[0]))
      @it = []


      t.size.times do |x|
        $app.para "\n",:height => 10
        $app.para t[x],:left => 10
        @it[x] = $app.edit_line :width => 100,:left => 100
      end
    end

    @config.map do |x|
      $content.fill "#000"
      $content.oval :top => x[1][0],:left => x[1][1],:width => 5,:height => 5
    end
  end
end
