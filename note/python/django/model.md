```
from django.db import models

class Person(models.Model):
  name = models.CharField(max_length=30)
  def __str__(self):
    return self.name
```

## 定义(外键、一对多、多对多)

采用Code First的主张，通过定义model class来定义数据表


`python manage.py migrate`，根据model class信息去定义或更新数据表

字段选项
null, False | True, 字段可空
blank, False | True, 字段可否为空字符串或空, 用于表单验证
choices, 子项目为2-tupples的可迭代对象(如list或tuple)，用于表单中以select表单元素显示内容.其中2-tupples中，第一个元素存储在数据表中，而第二个元素用于页面显示
通过实例的`get_字段名_display()`获取对应的2-tupples的第二个元素
default, 值或函数，当为函数时每次创建实例时均会调用
help_text, str, 帮助文档，会作为表单元素的title
primary_key, False | True, 指定该字段为主键。默认情况下会自动添加一个IntegerField且自增长的字段作为主键, 若某字段设置该选项则会覆盖默认设置。注意，若修改某记录的主键值并保存，则会生成一条新的记录，而不是真的更改该记录的主键值。
```
id = models.AutoField(primary_key=True)
```
unique, False | True, 字段值唯一


多对一`models.ForeignKey`
一个汽车厂对应多量汽车
```
class Car(models.Model):
  manufacturer = models.ForeignKey(Manufacturer, on_delete=models.CASCADE)
class Manufacturer(models.Model):
  pass
```

多对多`models.ManyToManyField`
注意：任意一个model class拥有这个字段也可以，但只可以一个拥有该字段
若要添加多对多关系的附加信息(实质上就是在中间表添加字段)
简单的多对多关系
```
class User(models.Model):
  name = models.CharField(max_length=30)
class Group(models.Model):
  name = models.CharField(max_length=30)
  users = models.ManyToManyField(User)
```
附加属性的多对多关系
```
class User(models.Model):
  name = models.CharField(max_length=30)
class Group(models.Model):
  name = models.CharField(max_length=30)
  users = models.ManyToManyField(User, through='Membership')
class Membership(models.Model):
  user = models.ForeignKey(User, on_delete=models.CASCADE)
  group = models.ForeignKey(Group, on_delete=models.CASCADE)
  date_joined = models.DateField()
```
创建记录,以中间表作为操作中心
```
john = User.objects.create(name='fsjohnhuang')
ef = Group.objects.create(name='FE')
m = Membership.objects.create(user=john, group=ef, date_joined=date(1962,8,16))
m.save()
```
实例相互获取数据
```
john.group_set.all()
ef.users.all()
```
类以中间表字段为条件获取数据
```
User.objects.filter(group__name__startwith='E')
Group.objects.filter(membership__date_joined__gt=date(1961,1,1))
```
只能通过clear清空记录
```
ef.users.clear()
```
一对一`models.OneToOneField`
当打算基于某个/些表扩展出新表时可以通过一对一关系创建
```
class Place(models.Model):
  addr = models.CharField(max_length=100)
class Restaurant(models.Model):
  brand = models.CharField(max_length=50)
  place = models.OneToOne(Place, on_delete=models.CASCADE, primary_key=True)
```
操作
```
p1 = Place(addr='1')
p1.save()
r1 = Restaurant(brand='2', place=p1)
r1.save()

if hasattr(p1, 'restaurant'):
  print p1.restaurant

print r1.place
```
on_delete的值范围
`models.CASCDE`，级联删除，当前记录随主记录删除而删除
`models.PROTECT`，要求先删除该记录后才能删除主记录，否则会抛出ProtectedError
`models.SET_NULL`, 当删除主记录后，将该字段这是为空
`models.SET_DEFAULT`, 当删除主记录后，将该字段这是为默认值
`models.SET(值/函数)`,
`models.DO_NOTHING`


查(单、多、精确查询、模糊查询、排序、排重)

类名.objects是Manager,用于操作数据表

增
```
u = User(name='john', age=18)
u.save() # 发起INSERT SQL请求
u.name = 'mary'
u.save() # 发起UPDATE SQL请求
```

查
QuerySet，记录的集合
`User.objects.all()`
`User.objects.filter()`
`User.objects.exclude()`

`User.objects.get()`
当0个记录时报DoesNotExist异常，当大于1个记录时会报MultipleObjectsReturned异常。

`User.objects.order_by()`

Field lookups, `field__lookuptype=value`

实例的delete方法是删除当前记录
表的delete则是批量删除记录

remove
clear
update()

删(级联)

