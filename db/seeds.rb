#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
['南京', '上海', '北京','苏州','广州','深圳','杭州'].each do |name|
  City.find_or_create_by_name(:name => name)
end

nanjing = City.find_by_name('南京')
shanghai = City.find_by_name('上海')
beijing = City.find_by_name('北京')
suzhou = City.find_by_name('苏州')
guangzhou = City.find_by_name('广州')
shenzhen = City.find_by_name('深圳')
hangzhou = City.find_by_name('杭州')

nanjing.pinyin = 'nanjing'
shanghai.pinyin = 'shanghai'
beijing.pinyin = 'beijing'
suzhou.pinyin = 'suzhou'
guangzhou.pinyin = 'guangzhou'
shenzhen.pinyin = 'shenzhen'
hangzhou.pinyin = 'hangzhou'
nanjing.save
shanghai.save
beijing.save
suzhou.save
guangzhou.save
shenzhen.save
hangzhou.save

['玄武区', '鼓楼区', '建邺区', '白下区', '秦淮区', 
 '下关区', '雨花台区', '栖霞区', '浦口区', '江宁区', '六合区', '溧水县', '高淳县'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => nanjing.id) 
end


['黄浦区','徐汇区','长宁区','静安区','普陀区','闸北区','虹口区','杨浦区','浦东新区','宝山区','闵行区',
 '嘉定区','金山区','松江区','青浦区','奉贤区','崇明县'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => shanghai.id)
end

[ '东城区','西城区','朝阳区','丰台区','石景山区','海淀区','门头沟区','房山区','通州区','顺义区','昌平区',
  '大兴区','怀柔区','平谷区','密云县','延庆县'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => beijing.id)
end

[ '吴中区','相城区','平江区','金阊区','沧浪区','高新区','工业园区','常熟市','昆山市','张家港市','吴江市',
  '太仓市'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => suzhou.id)    
end

[ '越秀区','天河区','白云区','荔湾区','萝岗区','黄埔区','海珠区','番禺区','花都区','南沙区','增城市','从化市' ].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => guangzhou.id)
end

[ '福田区','罗湖区','南山区','盐田区','宝安区','龙岗区'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => shenzhen.id)
end

[ '上城区','下城区','江干区','拱墅区','西湖区','滨江区','萧山区','余杭区','桐庐县','淳安县','建德市','富阳市',
  '临安市'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => hangzhou.id)
end



#init table items

image_path = '/images/items/'

[ {:name => '足球', :description => "速度，力量，激情，团队", :category_id => 1,
    :large => "#{image_path}soccer_large.jpg", :medium => "#{image_path}soccer_medium.png",
   :small => "#{image_path}soccer_small.png"},
  {:name => '篮球', :description => "你喜欢打篮球吗？", :category_id => 1,
    :large => "#{image_path}basketball_large.jpg", :medium => "#{image_path}basketball_medium.png",
    :small => "#{image_path}basketball_small.png"},
  {:name => '慢跑', :description => "轻松的步调，贵在坚持", :category_id => 1,
    :large => "#{image_path}running_large.jpg", :medium => "#{image_path}running_medium.png",
    :small => "#{image_path}running_small.png"},
  {:name => '网球', :description => "优美而激烈", :category_id => 1,
    :large => "#{image_path}tennis_large.jpg", :medium => "#{image_path}tennis_medium.png",
    :small => "#{image_path}tennis_small.png"},
  {:name => '单车', :description => "群聚或者独行，最重要是在路上的感觉",  :category_id => 1,
    :large => "#{image_path}cycling_large.jpg", :medium => "#{image_path}cycling_medium.png",
    :small => "#{image_path}cycling_small.png"},
  {:name => '登山', :description => "会当临绝顶，一览众山小", :category_id => 1,
    :large => "#{image_path}moutain_large.jpg", :medium => "#{image_path}moutain_medium.png",
    :small => "#{image_path}moutain_small.png"},
  {:name => '桌球', :description => "准确，力量，预判，运气",  :category_id => 1,
    :large => "#{image_path}pool_large.jpg", :medium => "#{image_path}pool_medium.png",
    :small => "#{image_path}pool_small.png"}, 
  {:name => '徒步', :description => "回归最原始",  :category_id => 1,
    :large => "#{image_path}walking_large.jpg", :medium => "#{image_path}walking_medium.png", 
    :small => "#{image_path}walking_small.png"}, 
  {:name => '垂钓', :description => "修身养性的选择", :category_id => 1,
    :large => "#{image_path}fishing_large.jpg", :medium => "#{image_path}fishing_medium.png",
    :small => "#{image_path}fishing_small.png"},
  {:name => '橄榄球', :description => "真正的男人运动", :category_id => 1,
    :large => "#{image_path}football_large.jpg", :medium => "#{image_path}football_medium.png",
    :small => "#{image_path}football_small.png"},
  {:name => '乒乓球', :description => "属于中国人的运动", :category_id => 1,
    :large => "#{image_path}pingpang_large.jpg", :medium => "#{image_path}pingpang_medium.png",
    :small => "#{image_path}pingpang_small.png"},
  {:name => '极限运动', :description => "展现最酷的你", :category_id => 1,
    :large => "#{image_path}skating_large.jpg", :medium => "#{image_path}skating_medium.png",
    :small => "#{image_path}skating_small.png"},
  {:name => '保龄球', :description => "绅士的休闲运动",  :category_id => 1,
    :large => "#{image_path}bowling_large.jpg", :medium => "#{image_path}bowling_medium.png",
    :small => "#{image_path}bowling_small.png"},
  {:name => '羽毛球', :description => "锻炼你的跳跃，反应和判断", :category_id => 1,
    :large => "#{image_path}badminton_large.jpg", :medium => "#{image_path}badminton_medium.png",
    :small => "#{image_path}badminton_small.png"},
  {:name => '游泳', :description => "夏天，清凉的泳池，动起来",  :category_id => 1,
    :large => "#{image_path}swimming_large.jpg", :medium => "#{image_path}swimming_medium.png",
    :small => "#{image_path}swimming_small.png"},
  {:name => '攀岩', :description => "追求身体的极限",  :category_id => 1,
    :large => "#{image_path}climing_large.jpg", :medium => "#{image_path}climing_medium.png",
    :small => "#{image_path}climing_small.png"},
  {:name => 'K歌', :description => "音乐，热情，释放", :category_id => 2,
    :large => "#{image_path}ktv_large.jpg", :medium => "#{image_path}ktv_medium.png",
    :small => "#{image_path}ktv_small.png"},
  {:name => '酒吧', :description => "释放激情", :category_id => 2,
    :large => "#{image_path}pub_large.jpg", :medium => "#{image_path}pub_medium.png",
    :small => "#{image_path}pub_small.png"},
  {:name => '桌游', :description => "趣味，休闲，当然还有智商", :category_id => 2,
    :large => "#{image_path}boardgame_large.jpg", :medium => "#{image_path}boardgame_medium.png",
    :small => "#{image_path}boardgame_small.png"},
  {:name => '野炊', :description => "吃得要爽", :category_id => 2,
    :large => "#{image_path}bbq_large.jpg", :medium => "#{image_path}bbq_medium.png",
    :small => "#{image_path}bbq_small.png"},
  {:name => '摄影', :description => "追逐光和影", :category_id => 2,
    :large => "#{image_path}photographing_large.jpg", :medium => "#{image_path}photographing_medium.png",
    :small => "#{image_path}photographing_small.png"},
  {:name => '聚餐', :description => "大胃王们你们还在闲着吗？", :category_id => 2,
    :large => "#{image_path}dinner_large.jpg", :medium => "#{image_path}dinner_medium.png",
    :small => "#{image_path}dinner_small.png"},
  {:name => '其他', :description => "以后开放的项目", :category_id => 0,
    :large => "#{image_path}others_large.jpg", :medium => "#{image_path}others_medium.png",
    :small => "#{image_path}others_small.png"}].each do |item|
    tmp = Item.find_or_create_by_name(:name => item[:name])
    tmp.update_attributes(:description => item[:description],
      :category_id => item[:category_id], :image_url_large => item[:large], 
      :image_url_medium => item[:medium], :image_url_small => item[:small])
  end

['体育运动', '休闲娱乐'].each do |name|
  Category.find_or_create_by_name(:name => name)
end

Event.all.each do |e|
  Album.find_or_create_by_imageable_id_and_name(:imageable_id => e.id,:name =>'default',:imageable_type => 'Event')
end

Person.all.each do |p|
  Album.find_or_create_by_imageable_id_and_name(:imageable_id =>p.id,:name => 'status_message',:imageable_type =>'Person')
  Album.find_or_create_by_imageable_id_and_name(:imageable_id =>p.id,:name => 'avatar',:imageable_type =>'Person')
end







