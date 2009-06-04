#! /usr/local/bin/shoes design.rb
class MolarWeight
  class << self
    def save(f)
      File.open(File.join($config_path,'molarweight'),'w+') do |x|
        x.syswrite(f)
      end
    end

    def edit
      $content.content do
        # 表格标题
        $app.edit_line '物质', :width => 150,:state => 'disabled'
        $app.edit_line '摩尔质量', :width => 150,:state => 'disabled'

        items = $content.flow
        ($molarweight || {}).map { |x| items.append{ add_row(x) }}

        # 空白行，用来向表单中添加内容
        $app.flow do
          2.times{ |y| $app.edit_line :width => 150 }
          $app.button "添加",:width => 100 do |x|
            arg = x.parent.children[0..1]
            items.append {add_row(arg.map(&:text))}
            arg.map {|x| x.text = ''}
          end
        end

        $content.button "保存",:width => 100 do
          $molarweight = {}
          items.children.map do |x|
            $molarweight.merge!(x.children[0].text => x.children[1].text)
          end

          save($molarweight.to_yaml)
        end
      end
    end

    def w_2_m(element,weight)
      if $molarweight[element].to_i > 0
        return (weight.to_f / $molarweight[element].to_f).to_s
      else
        $app.alert("请先设定#{element.strip}的摩尔量")
        return false
      end
    end

    # def m_2_w(args)
    #   return $molarweight[args].to_i if $molarweight[args].to_i > 0
    # end

    def add_row(args)
      return $app.flow do
        args.each { |x| $app.edit_line  x, :width => 150 }
        $app.button "删除",:width => 100 do |x| x.parent.remove end
      end
    end
  end
end
