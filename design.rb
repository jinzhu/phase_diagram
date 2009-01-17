#! /usr/local/bin/shoes design.rb

Shoes.setup do
  gem 'ruport'
end

$LOAD_PATH <<  File.dirname(__FILE__)

['ruport','yaml','symbol','panel','content','sidebar','pd'].each {|x| require x}


Shoes.app :width => 1200,:height => 800,:title => '相图分析' do
  background "#BBF".."#BB5", :angle => 0, :curve => 10

  $config_path = File.join(ENV['HOME'],".phase_diagram")
  Dir.mkdir($config_path) unless File.exist?($config_path)
  Dir.chdir($config_path)

  def draw_oval(opt = {})
    num  = opt[:num]
    left = opt[:left] || mouse[1]
    top  = opt[:top]  || mouse[2]

    $oval_num[num] ? $oval_num[num].move(left,top) :
      $oval_num[num] = (oval :left => left,:top => top,:height => 5,:width => 5,:center => true,:fill => "#fa0",:stroke => "#fa0")
  end

  def draw_p(opt = {})
    left = opt[:left] || mouse[1]
    top  = opt[:top]  || mouse[2]
    $p_num ||= []
    size = $p_num.size
    $p_num[size] = oval :left => left,:top => top,:height => 5,:width => 5,:center => true,:fill => "#f00",:stroke => "#f00"

    # 边栏显示所有成分及含量,及删除此点
    $p_num[size].hover do
      $notice.children[1].clear do
        opt[:msg].map do |k,v|
          para strong(k),"\n",:stroke => red
          para " "*5, strong(v.empty? ? 0 : v)," 摩尔\n",:stroke => "#00F"
        end
        $app.button "删除此点",:width => 150 do |x|
          x.parent.clear && $p_num[size].remove
        end
      end
    end
  end

  $app      = self
  $sidebar  = sidebar
  $content  = content
  $panel    = panel
  $oval_num = []
end
