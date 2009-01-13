class Pd
  attr :path,:config

  def initialize(args)
    @path   = File.join( CONFIG_PATH , args )
    @config = YAML.load_file(File.join( path ,'config'))
  end

  def show
    $content.image = File.join( @path , 'image' )


    table = File.exist?('element.csv') ? Table('element.csv') : []

    t = config.keys.concat(table.column(table.column_names[0]))
    @it = []

    t.size.times do |x|
      para "\n",:height => 10
      para t[x],:left => 10
      @it[x] = edit_line :width => 100,:left => 100
    end

    content(:path => File.join(dir,'image'))

    config.map do |x|
      oval :top => x[1][0],:left => x[1][1],:width => 5,:height => 5
    end
  end

end
