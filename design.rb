Shoes.setup do
  gem 'ruport'
end

$LOAD_PATH <<  File.dirname(__FILE__)

['ruport','yaml','symbol','panel','content','sidebar','pd'].each {|x| require x}


Shoes.app :width => 1000,:height => 800,:title => '相图分析' do
  # background '#aaa'..'#ddd',:angle => 90
  # CONFIG_PATH = "#{ENV['HOME']}/.phase_diagram"
  Dir.mkdir(CONFIG_PATH) unless File.exist?(CONFIG_PATH)
  Dir.chdir(CONFIG_PATH)

  sidebar
  $content = content(:path => '/pillar/HOME/Pictures/pict')
  panel
end
