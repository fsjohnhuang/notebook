python2.7

## `with as` statement / context manager
python 2.5后增加的语法


### REF
http://zhoutall.com/archives/325


源码(.py) -解析->　字节码(.pyc) 运行在 PVM上

Psyco实时编译器, 后期被PyPy取代
冻结二进制文件 = Python字节码 + PVM + 其他所有支持文件，即可直接执行的可执行文件。

## 模块
一个py文件一个模块
顶层模块亦称为脚本
不带扩展的文件名作为模块名称, 通过`__name__`属性获取，若为顶层模块那么`__name__`的值为`__main__`

文件格式
```
#!/usr/bin/env python
#-*- coding:utf-8 -*-

# python代码
```
其中`#!`称为hash bang，必须作为文件首行内容。而`/usr/bin/env`会从系统变量PATH中搜索python的解析器路径

内置模块:Python2.6`__builtin__`和Python3.x`builtins`


### 导入模块
  通过模块名称搜索模块，因此`<模块名称>`不包含目录
`import <模块名称>` 或 `from <模块名称> import <属性元组>`, 仅第一次导入时编译和执行模块，后续重复导入时仅直接使用pyc文件的字节码，并且不会再执行模块.
  重命名`import <模块名称> as <别名>`

因此导入模块Ａ后，要重新导入模块(重新执行编译和执行模块代码)则用`reload`函数重新加载
```
from imp import reload
reload(<模块变量>)
```
示例
```
import sort #必须先通过import加载模块后，才能使用reload重新加载该模块
from imp import reload
reload(sort)
```
注意：
1. 若sort.py中导入了其他模块，那么`reload`函数重新加载sort时不会导入sort中导入的模块，需要用`reload`函数逐一导入
2. `reload`返回值为加载的模块对象


## 对象类型
python中一切皆对象
类型存在于对象中，不存在于变量中。

### 数字(整数、浮点数、有虚部的复数、固定精度的十进制、带分子和分母的有理数)
整型(32bit整型　和　长整型-支持无限大整型，只要内存够大的话)
`int(str, base)`, 按base的进制将str转换为10进制的整型
十六进制:`Ox`开头; `hex(<integer>)`，将一个整型转行为16进制的字符串
八进制:`Oo`开头; `oct(<integer>)`，将一个整型转行为8进制的字符串
二进制:`Ob`开头; `bin(<integer>)`，将一个整型转行为2进制的字符串

```
# 带分子和分母的有理数
from fractions import Fraction
f = Fraction(2, 3)
f += 1
print(f) #Fraction(5,3)

# 固定精度浮点数
from decimal import Decimal
d = Decimal('0.3341')
d += 1
print(d) #Decimal('1.3341')
```

复数 = 实部(浮点数) + 虚部(浮点数)
```
c = 1 + -2j #复数
c2 = complex(1, -2)
i = 2j #纯虚数
```
可通过`cmath`工具操作

`str(val)`, 将对象val转换为用户友好的字符串
`repr(val)`, 将对象val转换为有额外细节的字符串

真除法: `/`, Python2.6则是整型间运算则等同于`//`, 浮点数时则保留小数；Python3则直接保留小数。
floor除法: `//`

数学模块`math`
而`pow`，`abs`等为inner function,不用导入而是在Python2.6的`__builtin__`或Python3.x的`builtins`模块中.
伪随机数`random`


### 字符串
`'test'`
不可变数据类型
字符串属于序列
特有操作
`str_obj.find(sub_str_obj)`, 查找子字符串首字母在字符串的位置，没有找到时返回-1
`str_obj.replace(old_str_obj, new_str_obj)`
`str_obj.upper()`
`str_obj.isalpha()`
`str_obj.isdigit()`
`str_obj.split(seperator)`, 以seperator将字符串拆分为一个序列
`str_obj.rstrip()`, strip the right most whitespace characters of the str_obj.

String Template
```
'%s something %s' % ('first string', '2nd string') #or
'{0} something {1}'.format('first string', '2nd string')
```
with hexadecimal, octal, binary
```
'%X %x %o' % (10,10,8) # A a 10
'{0:x} {1:o} {2:b}'.format(10,8,3) #a 10 11
```

convertions, operations for general data type is in the pattern as predefined inner function and expression such as `len(x)` and `x[0]`. the specific data type operations is in the pattern as method of the instance at that data type such as `aStr.upper()`.

raw-string means that string doesn't contain escape characters.
`r'string content'`

### 序列(List)
could contain different values in different data type. such as `[1, 'str', False]`
`[1,2]`  or `list((1,2,))`
可变数据类型

list comprehension expression
```
M = [1,2,3]

# create a new list
N = [k for k in M if k > 2]
print(N) # [3]

# create a new set
S = {k for k in M if k > 2}
print(S) # set([3])

# create a new dictionary
D = {k: k for k in M if k > 2}
print(D) # {3: 3}
```

### 元组(Tuple)
could contain different values in different data type. such as `(1, 'str', False,)`
`(1,2)`
不可变数据类型
specific method
```
tuple.index(<val>), return the index of that val
tuple.count(<val>), return the sum of that val
```

### 字典(Dictionary)
`{'key1': 'val1', 'key2': 'val2'}`
可变数据类型
不能使用切片操作

sort
```
d = {'foo':1, 'bar': 2}
# sort by keys in hand which would update the source
keys = d.keys()
for key in keys:
  print(d[key])

# sort by keys with inner function sorted which wouldn't update the source
for key in sorted(d):
  print(d[key])
```

access the key-value item by key
```
d = {'foo':1, 'bar': 2}
# get value by [] expression
print(d['foo']) # 1
print(d['foo1']) # throw KeyError

if 'foo1' in d:
  print(d['foo1'])
else:
  print(None)
print(d['foo1'] if 'foo1' in d else None)
print(d.get('foo1', None))
```

### 集合(Set)
`{1,2}` 或 `set([1,2])`
`{'1','2'}` 或 `set('12')`
可变数据类
不能用切片操作

`in`, membership
`&`,  intersection
`|`, union
`-`, different value
`^`, XOR
`>`, superset
`<`, subset

内部元素不能为List和Dictionary,要由复合元素时采用Tuple.(内部元素必须属于可散列的类型)

### None

### 布尔(Boolean)
`False`,`True`
`bool(<val>)`, convert the val to Boolean value

支持连续的逻辑运算
`1<2<3` 等价于 `1<2 and 2<3`
`1==2>3` 等价于 `1==2 and 2>3`　


### 类型对象
`type(<变量>)`,获取<变量>的类型对象
`isinstance(<变量>, <类型>)`, 检测<变量>是不是属于<类型>这个类型。

### 编程单元类型:(函数、模块、类)
函数
```
def say1(x):
  x = 1 ＃局部变量x
  print(x) 

def say2():
  global x ＃全局变量x,y
  x = 1
  print(x) 


x = 2
say1(x)   # 1
print(x) # 2

say2()   # 1
print(x) # 1
```
通过`global 变量1[,变量]`来声明全局变量

文档字符串(DocStrings)
用于对函数、类、模块进行描述。通过help()函数或`__doc__`属性获取。
格式:
首行为概述
第二行空行
第三行开始为详细描述
```
def say():
  '''Print the hello world.

  Just for test DocStrings.'''

say.__doc__
```

不定长入参
```
# args是元组
def powersum(power, *args):
  sum = 0
  for i in args:
    sum += pow(i, power)
  return sum

powersum(2, 3, 4 ,5)

# args是字典
def say(name, **args):
  print(args.get('test', 0))

say('john', test=1)
```

lambda表达式
```
id = lambda x: x
```


类
```
class Stu:
  field = 0 # 定义静态字段

  # 构造函数
  def __init__(self, name):
    self.name = name  # 通过self.name定义公共实例字段
    self._name = name #通过self._name定义私有实例字段

  # 公共实例方法
  def getName(self):
    return self.name

  # 私有实例方法
  def _getName(self):
    pass


  # 析构函数
  def __del__(self):
    pass

  def __str__(self):
    return 'Student %s' % (self.name) #使用print或str时会调用该方法

  def __lt__(self, other):
    return 1 # 当使用小于运算时会被调用

  def __gt__(self, other):
    return 1 # 当使用大于运算时会被调用

  def __getitem__(self, key):
    pass #使用x[key]索引操作符时会被调用

  def __len__(self):
    pass #使用len()时会被调用

stu = Stu('fsjohnhuang')
print(stu.name)
print(stu.getName())
```
双下划线会被Python名称管理体系识别为私有变量。
单下划线是Python风格的私有变量命名规范而已。

```
# Ｂ继承Stu
class B(Stu):
  def __init__(self, name):
    Stu.__init__(self, name) #调用父类的构造函数(Python不会自动调用，要我们手动调用)
```


RegExp
```
import re
match = re.match(<pattern_string>, <target_string>)
```
`match.group(0)`, return the match group by index, include the full match one.
`match.groups()`, return a tuple of match group by parenthesis
sample:
```
import re

match = re.match('[a-z]*', 'abc')
print(match.groups()) #()
print(match.group(0)) #abc
match = re.match('([a-z]*)', 'abc')
print(match.groups()) #('abc',)
print(match.group(1)) #abc
```

`**`, 次方

## IO
standard output: `print(<信息>)`
standard input: `input_str = input(<提示信息>)`

### File IO
file类

`open('<file_path>'[, '<modes>'])`, open a file descriptor.
```
<modes>
r, read. default value
w, write.
a, append.
b, binary.
sample: 
f = open('file.txt', 'rw')
```
specific method
`read([<count_of_bytes>])`, read content from file with bytes, if arguemnt bytes is ignored then read to the end of file.
`readline()`, read a line from the file
`seek(<count_of_bytes>)`, move the specific position
`close()`, close the file stream.


## for statement
Iteration Protocols
  operations that scanning from left to right must conform the iteration protocol.

list comprehension expression and functional programming tools would be more effective than for statement.

```
for i in range(0,3):
  print(i)
else:
  print('loop is over!')
```

Python对象持久化
可通过`pickle`或`cPickle`模块存储和读取任意的Python对象。
```
import cPickle as p

# 存储
nums = [1,2,3]
f = file('nums.obj', 'w')
p.dump(nums, f)
f.close()

# 读取
f = file('nums.obj')
myNums = p.load(f)
f.close()
```


## 异常机制(Error & Exception)
捕获异常
```
try:
  ...
except EOFError:
  # 捕捉EOFError后的善后代码
except (NameError, TypeError):
  # 捕捉多个Error后的善后代码
except:
  # 捕捉Error后的善后代码
else:
  # (可选)若没有发生异常则调用此处代码
finally:
  # (可选)无论发生异常与否均必须执行的代码
```
触发异常
```
raise Error()
```

## 常用工具函数
`dir(<变量>)`, 打印变量的所有属性.
`exec('<python代码片段>')`, 代码片段中的变量、函数会覆盖当前模块的同名变量、函数
```
exec(open('other.py').read())
```
`help(<变量>)`, show the help doc of the argument

`__<名称>__`,  Python预定义的内置变量

`time.sleep()`, 进程休眠一段时间
`time.strftime()`，返回指定格式的当前时间字符串
`sys.argv`, 获取命令入参元组
`sys.exit()`, 退出系统
`os.system()`, 执行系统命令，正常则返回０，否则返回错误码
`os.path.exists()`,　检查是否有指定的目录
`os.mkdir(strDir)`, 创建指定目录
`os.sep`, 系统目录的分隔符，xnix采用`/`，而windows采用`\`, MAC OS采用`:`
`os.linesep`, 系统的行终止符, xnix采用`\n`，而windows采用`\r\n`,而MAC OS采用`\r`
`os.getcwd()`，获取当前工作目录
`os.getenv()`和`os.putenv()`, 获取和设置环境变量
`os.listdir()`,返回指定目录下的所有文件和目录名称
`os.remove()`,删除指定文件
`os.path.isfile()`, 是否为文件
`os.path.isdir()`，是否为目录
`os.path.exist()`，是否存在

逻辑行
```
res = 1 + 2 + \
  3 + 4

#等价于
res = 1 + 2 + 3 + 4
```

变量不需要预定义，但使用前需要先赋值。
