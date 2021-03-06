$KCODE = 'UTF8'

# Freeze Gems
$LOAD_PATH <<  File.dirname(__FILE__) << File.join(File.dirname(__FILE__),'gems','ruport-1.6.1','lib') << File.join(File.dirname(__FILE__),'gems','fastercsv-1.2.3','lib') << File.join(File.dirname(__FILE__),'gems','pdf-writer-1.1.8','lib')

['ruport','fastercsv','yaml','symbol','panel','content','sidebar','pd','molar_weight','iconv'].each {|x| require x}


Shoes.app :width => 1200,:height => 800,:title => '相图分析' do
  background "#BBF".."#BB5", :angle => 0, :curve => 10

  # def button *txt
  #   txt[0] = Iconv.conv('gb18030','utf-8',txt[0])
  #   super
  # end

  $config_path = File.join(ENV['HOME'] || ENV["USERPROFILE"],".phase_diagram")
  Dir.mkdir($config_path) unless File.exist?($config_path)
  Dir.chdir($config_path)

  def draw_oval(opt = {})
    num  = opt[:num]
    left = opt[:left] || mouse[1]
    top  = opt[:top]  || mouse[2]

    $oval_num[num].remove if $oval_num[num]
    $oval_num[num] = (oval :left => left,:top => top,:height => 3,:width => 3,:center => true,:fill => "#fa0",:stroke => "#fa0")
  end

  def draw_p(opt = {})
    left = opt[:left] || mouse[1]
    top  = opt[:top]  || mouse[2]
    return false  unless (left > 0 && top > 0)
    # return false unless [left,top].all
    $p_num ||= []
    size = $p_num.size
    $p_num[size] = oval :left => left,:top => top,:height => 3,:width => 3,:center => true,:fill => "#f00",:stroke => "#f00"

    # 边栏显示所有成分及含量,及删除此点
    $p_num[size].hover do
      $notice.children[1].clear do
        stack do
          opt[:msg].map do |k,v|
            stack :width => 200 do
              background "#FFD900"
              para strong(k),:stroke => red
            end
            stack :width => 200 do
              para strong(MolarWeight.m_2_w(k,v)),strong(" 摩尔"),:stroke => "#00F"
            end
          end

          $app.button "删除此点",:width => 200,:left => -20 do |x|
            x.parent.clear && $p_num[size].remove
          end
        end
      end
    end
  end

  $app         = self
  $sidebar     = sidebar
  $content     = content
  $panel       = panel
  $oval_num    = []
  $molarweight = YAML.load_file(File.join($config_path,'molarweight')) if File.exist?(File.join($config_path,'molarweight'))
end
