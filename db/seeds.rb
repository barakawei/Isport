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
