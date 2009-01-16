#! /usr/local/bin/shoes design.rb
module Position
  def setvar
    #               -- 0
    #              -  -
    #             -    -
    #            -      -
    #           -        -
    #          -          -
    #         -            -
    #      1 ---------------- 2
    @p ||= @config.values

    # 三角形三个边长的距离
    @l01 ||= Math.sqrt((@p[0][0]-@p[1][0])**2 + (@p[0][1]-@p[1][1])**2)
    @l12 ||= Math.sqrt((@p[2][0]-@p[1][0])**2 + (@p[2][1]-@p[1][1])**2)
    @l02 ||= Math.sqrt((@p[2][0]-@p[0][0])**2 + (@p[2][1]-@p[0][1])**2)

    # 余弦定理，角 1 的余弦值
    @c_a_1 ||= (@l01**2 + @l12**2 - @l02**2)/(2*@l01*@l12)
    # 角 1 的正弦值
    @s_a_1 ||= Math.sqrt(1 - @c_a_1**2)

    # 以 0/2 为顶点的三角形的高
    @h0 ||= @l01*@s_a_1
    @h2 ||= @l12*@s_a_1

    # 各边的斜率
    @k01 ||= Float(@p[1][1]-@p[0][1])/Float(@p[1][0]-@p[0][0])
    @k02 ||= Float(@p[2][1]-@p[0][1])/Float(@p[2][0]-@p[0][0])
    @k12 ||= Float(@p[2][1]-@p[1][1])/Float(@p[2][0]-@p[1][0])
  end

  def triangle(opt={})
    k = opt.values  # 成分含量
    sum = 0
    k.map  {|x| Float( sum+=x )}  # 成分的总摩尔量
    k.map! {|x| Float(  x/sum )}  # 成分占总成分的摩尔百分比

    setvar

    # y = k*x + c
    # (p[1][1]-k01*p[1][0])求出物质位置通过的平行线的常数 c
    # ph2/Math.cos(Math.atan(k01)) 根据百分比求出偏移距离
    c0 = @p[1][1] - @k12*@p[1][0] + @h0*k[0]/Math.cos(Math.atan(@k12))
    c2 = @p[1][1] - @k01*@p[1][0] + @h2*k[2]/Math.cos(Math.atan(@k01))

    # k01*x + c2 = k12*x + c0
    x = (c0 - c2)/(@k01-@k12)
    y = @k01*x + c2
    $app.draw_p(:top => y,:left => x)
  end

  def get_percent(args)
    setvar

    c0  = (args[1] - @k12*args[0])-(@p[1][1] - @k12*@p[1][0])
    c2  = (args[1] - @k01*args[0])-(@p[1][1] - @k01*@p[1][0])
    ph0 = c0*Math.cos(Math.atan(@k12))/@h0
    ph2 = c2*Math.cos(Math.atan(@k01))/@h2

    if (ph0 + ph2 <= 1.01) && ph0 > -0.01 && ph2 > -0.01
      keys   = @config.keys.join(" : ")
      result = [ph0,1-ph2-ph0,ph2].map {|x| truncate(x)}.join(" : ")

      @rt_p.text = $app.strong(keys) ," = ",$app.strong(result)
    else
      @rt_p.text = ''
    end
  end

  def truncate(args)
    Float((args*10e6).round/10e6).to_s
  end
end
