#! /usr/local/bin/shoes design.rb

Shoes.setup do
  gem 'ruport'
end

$LOAD_PATH <<  File.dirname(__FILE__)

['ruport','yaml','symbol','panel','content','sidebar','pd'].each {|x| require x}


Shoes.app :width => 1000,:height => 800,:title => '相图分析' do
  # background '#aaa'..'#ddd',:angle => 90
  # CONFIG_PATH = "#{ENV['HOME']}/.phase_diagram"
  $config_path = File.join(ENV['HOME'],".phase_diagram")
  Dir.mkdir($config_path) unless File.exist?($config_path)
  Dir.chdir($config_path)

  def draw_oval(opt = {})
    num  = opt[:num]
    left = opt[:left] || mouse[1]
    top  = opt[:top]  || mouse[2]

    $oval_num[num] ? $oval_num[num].move(left,top) :
      $oval_num[num] = (oval :left => left,:top => top,:height => 5,:width => 5,:center => true,:fill => red)
  end

  def draw_p(opt = {})
    left = opt[:left] || mouse[1]
    top  = opt[:top]  || mouse[2]

    oval :left => left,:top => top,:height => 15,:width => 15,:center => true,:fill => green
  end

  $app      = self
  $sidebar  = sidebar
  $content  = content
  $panel    = panel
  $oval_num = []

  $current_item = Pd.new('A')
  $current_item.show
  # oval :left => 500,:top => 500,:height => 15,:width => 15,:center => true,:fill => green
end
