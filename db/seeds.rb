#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#init all provinces and cities

#encoding: utf-8
city_file_name = "./db/citys.txt"
if FileTest.exist?(city_file_name)
  i_file = File.new(city_file_name, "r")
  province = false
  city = false
  pinyin = false

  province_id = 0
  city_id = 0

  city_name_modify = true
  i_file.each_line do |line|
    if province
      line.strip!
      line.delete! "省"
      if line != "特别行政区"
        line.delete! "自治区"
      end
      if province_id != 0
        City.find_or_create_by_name_and_province_id(:name => "其他", :province_id => province_id)
      end
      tmp = Province.find_or_create_by_name(:name => line)
      province_id = tmp.id
      province = false
      if line == "台湾"
        city_name_modify = false
      else
        city_name_modify = true
      end
    elsif city
      line.strip!
      if city_name_modify
        line.delete! "市"
      end
      tmp = City.find_or_create_by_name(:name => line)
      tmp.update_attributes(:province_id => province_id)
      city_id = tmp.id
      city=false
      pinyin = true
    else
      if line == "city_change\n"
        city = true
        province = false
      elsif line == "province_change\n"
        city = false
        province = true
      else
        if pinyin
          line.strip!
          tmp = City.find(city_id)
          tmp.update_attributes(:pinyin => line)
          pinyin = false
        else
          line.strip!
          District.find_or_create_by_name_and_city_id(:name => line, :city_id => city_id)
        end
        city = false
        province = false
      end
    end
  end
  i_file.close
else
  puts "File #{city_file_name} do not exist"
end


#init table items

image_path = '/images/items/'

[ {:name => '足球', :description => "速度，力量，激情，团队", :category_id => 1,
    :large => "#{image_path}soccer_large.jpg", :medium => "#{image_path}soccer_medium.jpg",
   :small => "#{image_path}soccer_small.png"},
  {:name => '篮球', :description => "你喜欢打篮球吗？", :category_id => 1,
    :large => "#{image_path}basketball_large.jpg", :medium => "#{image_path}basketball_medium.jpg",
    :small => "#{image_path}basketball_small.png"},
  {:name => '慢跑', :description => "轻松的步调，贵在坚持", :category_id => 1,
    :large => "#{image_path}running_large.jpg", :medium => "#{image_path}running_medium.jpg",
    :small => "#{image_path}running_small.png"},
  {:name => '网球', :description => "优美而激烈", :category_id => 1,
    :large => "#{image_path}tennis_large.jpg", :medium => "#{image_path}tennis_medium.jpg",
    :small => "#{image_path}tennis_small.png"},
  {:name => '单车', :description => "群聚或者独行，最重要是在路上的感觉",  :category_id => 1,
    :large => "#{image_path}cycling_large.jpg", :medium => "#{image_path}cycling_medium.jpg",
    :small => "#{image_path}cycling_small.png"},
  {:name => '登山', :description => "会当临绝顶，一览众山小", :category_id => 1,
    :large => "#{image_path}moutain_large.jpg", :medium => "#{image_path}moutain_medium.jpg",
    :small => "#{image_path}moutain_small.png"},
  {:name => '桌球', :description => "准确，力量，预判，运气",  :category_id => 2,
    :large => "#{image_path}pool_large.jpg", :medium => "#{image_path}pool_medium.jpg",
    :small => "#{image_path}pool_small.png"}, 
  {:name => '徒步', :description => "回归最原始",  :category_id => 1,
    :large => "#{image_path}walking_large.jpg", :medium => "#{image_path}walking_medium.jpg", 
    :small => "#{image_path}walking_small.png"}, 
  {:name => '垂钓', :description => "修身养性的选择", :category_id => 2,
    :large => "#{image_path}fishing_large.jpg", :medium => "#{image_path}fishing_medium.jpg",
    :small => "#{image_path}fishing_small.png"},
  {:name => '橄榄球', :description => "真正的男人运动", :category_id => 1,
    :large => "#{image_path}football_large.jpg", :medium => "#{image_path}football_medium.jpg",
    :small => "#{image_path}football_small.png"},
  {:name => '乒乓球', :description => "属于中国人的运动", :category_id => 1,
    :large => "#{image_path}pingpang_large.jpg", :medium => "#{image_path}pingpang_medium.jpg",
    :small => "#{image_path}pingpang_small.png"},
  {:name => '极限运动', :description => "展现最酷的你", :category_id => 1,
    :large => "#{image_path}skating_large.jpg", :medium => "#{image_path}skating_medium.jpg",
    :small => "#{image_path}skating_small.png"},
  {:name => '保龄球', :description => "绅士的休闲运动",  :category_id => 1,
    :large => "#{image_path}bowling_large.jpg", :medium => "#{image_path}bowling_medium.jpg",
    :small => "#{image_path}bowling_small.png"},
  {:name => '羽毛球', :description => "锻炼你的跳跃，反应和判断", :category_id => 1,
    :large => "#{image_path}badminton_large.jpg", :medium => "#{image_path}badminton_medium.jpg",
    :small => "#{image_path}badminton_small.png"},
  {:name => '游泳', :description => "夏天，清凉的泳池，动起来",  :category_id => 1,
    :large => "#{image_path}swimming_large.jpg", :medium => "#{image_path}swimming_medium.jpg",
    :small => "#{image_path}swimming_small.png"},
  {:name => '攀岩', :description => "追求身体的极限",  :category_id => 1,
    :large => "#{image_path}climing_large.jpg", :medium => "#{image_path}climing_medium.jpg",
    :small => "#{image_path}climing_small.png"},
  {:name => 'K歌', :description => "音乐，热情，释放", :category_id => 2,
    :large => "#{image_path}ktv_large.jpg", :medium => "#{image_path}ktv_medium.jpg",
    :small => "#{image_path}ktv_small.png"},
  {:name => '酒吧', :description => "释放激情", :category_id => 2,
    :large => "#{image_path}pub_large.jpg", :medium => "#{image_path}pub_medium.jpg",
    :small => "#{image_path}pub_small.png"},
  {:name => '桌游', :description => "趣味，休闲，当然还有智商", :category_id => 2,
    :large => "#{image_path}boardgame_large.jpg", :medium => "#{image_path}boardgame_medium.jpg",
    :small => "#{image_path}boardgame_small.png"},
  {:name => '野炊', :description => "吃得要爽", :category_id => 2,
    :large => "#{image_path}bbq_large.jpg", :medium => "#{image_path}bbq_medium.jpg",
    :small => "#{image_path}bbq_small.png"},
  {:name => '摄影', :description => "追逐光和影", :category_id => 2,
    :large => "#{image_path}photographing_large.jpg", :medium => "#{image_path}photographing_medium.jpg",
    :small => "#{image_path}photographing_small.png"},
  {:name => '聚餐', :description => "大胃王们你们还在闲着吗？", :category_id => 2,
    :large => "#{image_path}dinner_large.jpg", :medium => "#{image_path}dinner_medium.jpg",
    :small => "#{image_path}dinner_small.png"},
  {:name => '电影', :description => "艺术的集大成者", :category_id => 2,
    :large => "#{image_path}movie_large.jpg", :medium => "#{image_path}movie_medium.jpg",
    :small => "#{image_path}movie_small.png"},
  {:name => '旅行', :description => "去心灵想去的地方", :category_id => 2,
    :large => "#{image_path}travel_large.jpg", :medium => "#{image_path}travel_medium.jpg",
    :small => "#{image_path}travel_small.png"},
  {:name => '街舞', :description => "释放青春的舞蹈", :category_id => 1,
    :large => "#{image_path}hiphop_large.jpg", :medium => "#{image_path}hiphop_medium.jpg",
    :small => "#{image_path}hiphop_small.png"},
  {:name => '电子竞技', :description => "小屏幕，大世界", :category_id => 2,
    :large => "#{image_path}egame_large.jpg", :medium => "#{image_path}egame_medium.jpg",
    :small => "#{image_path}egame_small.png"},
  {:name => '动漫', :description => "属于梦想的东西", :category_id => 2,
    :large => "#{image_path}cartoon_large.jpg", :medium => "#{image_path}cartoon_medium.jpg",
    :small => "#{image_path}cartoon_small.png"},
  {:name => '模型玩具', :description => "让那个存在你心中的世界变得真实", :category_id => 2,
    :large => "#{image_path}toys_large.jpg", :medium => "#{image_path}toys_medium.jpg",
    :small => "#{image_path}toys_small.png"},
  {:name => '购物', :description => "血拼去吧！", :category_id => 2,
    :large => "#{image_path}shopping_large.jpg", :medium => "#{image_path}shopping_medium.jpg",
    :small => "#{image_path}shopping_small.png"},
  {:name => '自驾游', :description => "纵情天地间", :category_id => 2,
    :large => "#{image_path}driving_large.jpg", :medium => "#{image_path}driving_medium.jpg",
    :small => "#{image_path}driving_small.png"},
  {:name => '电视剧', :description => "消遣时间的好办法", :category_id => 2,
    :large => "#{image_path}tvplay_large.jpg", :medium => "#{image_path}tvplay_medium.jpg",
    :small => "#{image_path}tvplay_small.png"},
  {:name => '阅读', :description => "获取只是，提升修养", :category_id => 2,
    :large => "#{image_path}reading_large.jpg", :medium => "#{image_path}reading_medium.jpg",
    :small => "#{image_path}reading_small.png"},
  {:name => '音乐', :description => "用双耳去欣赏世界", :category_id => 2,
    :large => "#{image_path}music_large.jpg", :medium => "#{image_path}music_medium.jpg",
    :small => "#{image_path}music_small.png"},
  {:name => '宠物', :description => "秀出你的爱心吧", :category_id => 2,
    :large => "#{image_path}pats_large.jpg", :medium => "#{image_path}pats_medium.jpg",
    :small => "#{image_path}pats_small.png"},
  {:name => '瑜伽', :description => "伸展到最大", :category_id => 1,
    :large => "#{image_path}yoga_large.jpg", :medium => "#{image_path}yoga_medium.jpg",
    :small => "#{image_path}yoga_small.png"},
  {:name => '跆拳道', :description => "搏击，击破", :category_id => 1,
    :large => "#{image_path}taekwondo_large.jpg", :medium => "#{image_path}taekwondo_medium.jpg",
    :small => "#{image_path}taekwondo_small.png"},
  {:name => '健身', :description => "在节奏中赶走你的脂肪", :category_id => 1,
    :large => "#{image_path}bodybuilding_large.jpg", :medium => "#{image_path}bodybuilding_medium.jpg",
    :small => "#{image_path}bodybuilding_small.png"},
  {:name => 'Photoshop', :description => "神奇的魔术棒", :category_id => 3,
    :large => "#{image_path}ps_large.jpg", :medium => "#{image_path}ps_medium.jpg",
    :small => "#{image_path}ps_small.png"},
  {:name => '智能手机', :description => "掌中的精灵", :category_id => 3,
    :large => "#{image_path}smartphone_large.jpg", :medium => "#{image_path}smartphone_medium.jpg",
    :small => "#{image_path}smartphone_small.png"},
  {:name => '桌面系统', :description => "Mac?Linux?Win?最重要的是适合你", :category_id => 3,
    :large => "#{image_path}os_large.jpg", :medium => "#{image_path}os_medium.jpg",
    :small => "#{image_path}os_small.png"},
  {:name => '互联网', :description => "这里，你将有机会改变世界", :category_id => 3,
    :large => "#{image_path}internet_large.jpg", :medium => "#{image_path}internet_medium.jpg",
    :small => "#{image_path}internet_small.png"},
  {:name => '苹果', :description => "Think different, 不断创新的苹果", :category_id => 3,
    :large => "#{image_path}apple_large.jpg", :medium => "#{image_path}apple_medium.jpg",
    :small => "#{image_path}apple_small.png"},
  {:name => '其他', :description => "以后开放的项目", :category_id => 0,
    :large => "#{image_path}others_large.jpg", :medium => "#{image_path}others_medium.jpg",
    :small => "#{image_path}others_small.png"}].each do |item|
    tmp = Item.find_or_create_by_name(:name => item[:name])
    tmp.update_attributes(:description => item[:description],
      :category_id => item[:category_id], :image_url_large => item[:large], 
      :image_url_medium => item[:medium], :image_url_small => item[:small])
  end

['体育运动', '休闲娱乐', '信息技术'].each do |name|
  Category.find_or_create_by_name(:name => name)
end

