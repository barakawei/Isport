#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
['南京', '上海', '北京'].each do |name|
  City.find_or_create_by_name(:name => name)
end

nanjing = City.find_by_name('南京')
shanghai = City.find_by_name('上海')
beijing = City.find_by_name('北京')
nanjing.pinyin = 'nanjing'
shanghai.pinyin = 'shanghai'
beijing.pinyin = 'beijing'
nanjing.save
shanghai.save
beijing.save

['宣武区', '鼓楼区', '建邺区', '白下区', '秦淮区', 
 '下关区', '雨花台区', '栖霞区', '浦口区', '江宁区', '六合区', '溧水县', '高淳县'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => nanjing.id) 
end

gulou = District.find_by_name('鼓楼')

['黄浦区','徐汇区','长宁区','静安区','普陀区','闸北区','虹口区','杨浦区','浦东新区','宝山区','闵行区',
 '嘉定区','金山区','松江区','青浦区','奉贤区','崇明县'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => shanghai.id)
end

[ '东城区','西城区','朝阳区','丰台区','石景山区','海淀区','门头沟区','房山区','通州区','顺义区','昌平区',
  '大兴区','怀柔区','平谷区','密云县','延庆县'].each do |name|
  District.find_or_create_by_name(:name => name, :city_id => beijing.id)
end

#init table items

image_path = '/images/items/'

[ {:name => '足球', :description => "速度，力量，激情，团队",
    :large => "#{image_path}soccer_large.jpg", :medium => "#{image_path}soccer_medium.jpg",
   :small => "#{image_path}soccer_small.jpg"},
  {:name => '篮球', :description => "xx",
    :large => "#{image_path}basketball_large.jpg", :medium => "#{image_path}basketball_medium.jpg",
    :small => "#{image_path}basketball_small.jpg"},
  {:name => '慢跑', :description => "xx",
    :large => "#{image_path}running_large.jpg", :medium => "#{image_path}running_medium.jpg",
    :small => "#{image_path}running_small.jpg"},
  {:name => '网球', :description => "xx",
    :large => "#{image_path}tennis_large.jpg", :medium => "#{image_path}tennis_medium.jpg",
    :small => "#{image_path}tennis_small.jpg"},
  {:name => '单车', :description => "xx", 
    :large => "#{image_path}cycling_large.jpg", :medium => "#{image_path}cycling_medium.jpg",
    :small => "#{image_path}cycling_small.jpg"},
  {:name => '登山', :description => "xx",
    :large => "#{image_path}moutain_large.jpg", :medium => "#{image_path}moutain_medium.jpg",
    :small => "#{image_path}moutain_small.jpg"},
  {:name => '桌球', :description => "xx", 
    :large => "#{image_path}pool_large.jpg", :medium => "#{image_path}pool_medium.jpg",
    :small => "#{image_path}pool_small.jpg"}, 
  {:name => '徒步', :description => "xx", 
    :large => "#{image_path}walking_large.jpg", :medium => "#{image_path}walking_medium.jpg", 
    :small => "#{image_path}walking_small.jpg"}, 
  {:name => '垂钓', :description => "xx",
    :large => "#{image_path}fishing_large.jpg", :medium => "#{image_path}fishing_medium.jpg",
    :small => "#{image_path}fishing_small.jpg"},
  {:name => '橄榄球', :description => "xx",
    :large => "#{image_path}football_large.jpg", :medium => "#{image_path}football_medium.jpg",
    :small => "#{image_path}football_small.jpg"},
  {:name => '乒乓球', :description => "xx",
    :large => "#{image_path}pingpang_large.jpg", :medium => "#{image_path}pingpang_medium.jpg",
    :small => "#{image_path}pingpang_small.jpg"},
  {:name => '轮滑', :description => "xx",
    :large => "#{image_path}skating_large.jpg", :medium => "#{image_path}skating_medium.jpg",
    :small => "#{image_path}skating_small.jpg"},
  {:name => '保龄球', :description => "xx", 
    :large => "#{image_path}bowling_large.jpg", :medium => "#{image_path}bowling_medium.jpg",
    :small => "#{image_path}bowling_small.jpg"},
  {:name => '羽毛球', :description => "xx",
    :large => "#{image_path}badminton_large.jpg", :medium => "#{image_path}badminton_medium.jpg",
    :small => "#{image_path}badminton_small.jpg"},
  {:name => '游泳', :description => "xx", 
    :large => "#{image_path}swimming_large.jpg", :medium => "#{image_path}swimming_medium.jpg",
    :small => "#{image_path}swimming_small.jpg"},
  {:name => '攀岩', :description => "xx", 
    :large => "#{image_path}climing_large.jpg", :medium => "#{image_path}climing_medium.jpg",
    :small => "#{image_path}climing_small.jpg"}].each do |item|
    Item.find_or_create_by_name(:name => item[:name], :description => item[:description],
      :image_url_large => item[:large], :image_url_medium => item[:medium], :image_url_small => item[:small])
  end










