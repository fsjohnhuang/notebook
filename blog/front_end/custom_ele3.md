# WebComponent魔法堂:深究Custom Element 之 从过去看现在

## 前言 
&emsp;说起Custom Element那必然会想起那个相似而又以失败告终的HTML Component。HTML Component是在IE5开始引入的新技术，用于对原生元素作功能"增强"，虽然仅仅被IE所支持，虽然IE10也开始放弃它了，虽然掌握了也用不上，但还是不影响我们以研究的心态去了解它的:)

## 把玩HTML Component
&emsp;HTML Component简称HTC，它由定义和应用两部分组成。定义部分写在`.htc`文件中(MIME为text/x-component)，由HTC独有标签、JScript和全局对象(`element`,`window`等)组成；而应用部分则写在html文件中，通过CSS的behavior规则附加到特定的元素上。
### 定义部分
&emsp;**HTC独有标签**
`PUBLIC:COMPONENT`, 根节点.
`PUBLIC:PROPERTY`, 定义元素公开自定义属性/特性.
&emsp;属性
&emsp;`NAME`，html文件中使用的属性名
&emsp;`INTERNALNAME`，htc文件内使用的属性名,默认与`NAME`一致
&emsp;`VALUE`，属性默认值
&emsp;`PUT`，setter对应的函数名
&emsp;`GET`，getter对应的函数名
`PUBLIC:EVENT`, 定义元素公开自定义事件.
&emsp;属性
&emsp;`NAME`，公开事件名称，如onheadingchange
&emsp;`ID`，htc内使用的事件名称，如ohc.然后通过`ohc.fire(createEventObject())`来触发事件
`PUBLIC:ATTACH`，订阅事件
&emsp;属性
&emsp;`EVENT`，订阅的事件名称，如onheadingchange
&emsp;`ONEVENT`，事件处理函数体，如headingchangehandler()
&emsp;`FOR`，事件发生的宿主(`element`,`document`,`window`,默认是`element`)
`PUBLIC:METHOD`, 定义元素公开方法
&emsp;属性
&emsp;`NAME`，html文件中使用的方法名
&emsp;`INTERNALNAME`，htc文件内使用的方法名,默认与`NAME`一致。在JScript中实现具体的方法体
`PUBLIC:DEFAULTS`，设置HTC默认配置
&emsp;**HTC生命周期事件**
`ondocumentready`, 添加到DOM tree时触发，在oncontentready后触发
`oncontentready`, 添加到DOM tree时触发
`ondetach`, 脱离DOM tree时触发, 刷新页面时也会触发
`oncontentsave`, 当复制(ctrl-c)element内容时触发
&emsp;**HTC全局对象**
`element`, 所附加到的元素实例
`runtimeStyle`，所附加到的元素实例的style属性
`document`，html的文档对象
&emsp;**HTC全局函数**
`createEventObject()`，创建事件对象
`attachEvent(evtName, handler)`, 订阅事件.注意：一般不建议使用attachEvent来订阅事件，采用`<PUBLIC:ATTACH>`来订阅事件，它会自动帮我们执行detach操作，避免内存泄露.
`detachEvent(evtName[, handler])`, 取消订阅事件

### 应用部分
**引入.htc**
1.基本打开方式
```
<style>
  css-selector{
    behavior: url(file.htc);
  }
</style>
```
2.打开多个
```
<style>
  css-selector{
    behavior: url(file1.htc) url(file2.htc);
  }
</style>
```
&emsp;可以看到是通过css-selector匹配元素然后将htc附加到元素上，感觉是不是跟AngularJS通过属性E指定附加元素的方式差不多呢!
3.自定义元素
```
<html xmlns:x>
    <head>
        <style>
            x\:alert{
                behavior: url(x-alert.htc);
            }
        </style>
    </head>
    <body>
        <x:alert></x:alert>
    </body>
</html>
```
&emsp;自定义元素则有些麻烦，就是要为自定义元素指定命名空间`x:alert`，然后在html节点上列出命名空间`xmlns:x`。(可多个命名空间并存`<html xmlns:x xmlns:y>`)
&emsp;下面我们来尝试定义一个`x:alert`元素来看看具体怎么玩吧！

### 自定义`x:alert`元素
x-alert.htc
```
<PUBLIC:COMPONENT>
    <PUBLIC:ATTACH EVENT="oncontentready" ONEVENT="onattach()"></PUBLIC:ATTACH>
    <PUBLIC:ATTACH EVENT="ondetach" ONEVENT="ondetach()"></PUBLIC:ATTACH>

    <PUBLIC:METHOD NAME="close"></PUBLIC:METHOD>
    <PUBLIC:METHOD NAME="show"></PUBLIC:METHOD>

    <PUBLIC:PROPERTY NAME="heading" PUT="putHeading" SET="setHeading"></PUBLIC:PROPERTY>
    <PUBLIC:EVENT NAME="onheadingchange" ID="ohc"></PUBLIC:EVENT>
    <PUBLIC:ATTACH EVENT="onclick" ONEVENT="onclick()"></PUBLIC:ATTACH>

    <script language="JScript">
        /* 
         * private region
         */
        function toArray(arrayLike, sIdx, eIdx){
           return Array.prototype.slice.call(arrayLike, sIdx || 0, eIdx || arrayLike.length)
        }
        function curry(fn /*, ...args*/){
            var len = fn.length
              , args = toArray(arguments, 1)

            return len <= args.length 
                   ? fn.apply(null, args.slice(0, len)) 
                   : function next(args){
                        return function(){
                            var tmpArgs = args.concat(toArray(arguments))
                            return len <= tmpArgs.length ? fn.apply(null, tmpArgs.slice(0, len)) : next(tmpArgs)
                        }
                     }(args)
        }
        function compile(tpl, ctx){
            var k
            for (k in ctx){
                tpl = tpl.replace(RegExp('\$\{' + k + '\}'), ctx[k]
            }
            return tpl
        }

        // 元素内部结构
        var tpl = '<div class="alert alert-warning alert-dismissible fade in">\
                        <button type="button" class="close" aria-label="Close">\
                          <span aria-hidden="true">&times;</span>\
                        </button>\
                        <div class="content">${raw}</div>\
                      </div>'
        var getHtml = curry(compile, tpl)
        /* 
         * leftcycle region
         */
        var inited = 0, oHtml = ''
        function onattach(){
            if (inited) return

            oHtml = element.innerHTML
            var ctx = {
                raw: heading + oHtml
            }
            var html = genHtml(ctx)
            element.innerHTML = html

            runtimeStyle.display = 'block'
            runtimeStyle.border = 'solid 1px red'
        }
        function ondetach(){}
        /* 
         * public method region
         */
        function show(){
            runtimeStyle.display = 'block'
        }
        function close(){
            runtimeStyle.display = 'none'
        }
        /*
         * public property region
         */
        var heading = ''
        function putHeading(val){
            if (heading !== val){
                setTimeout(function(){
                    var evt = createEventObject()
                    evt.propertyName = 'heading'
                    ohc.fire(evt)
                }, 0)
            }
            heading = val
        }
        function getHeading(){
            return heading
        }

        /*
         * attach event region
         */
        function onclick(){
            if (/^\s*close\s*$/.test(event.srcElement.className)){
                close()
            }
        }
    </script>
</PUBLIC:COMPONENT>
```
### 引用`x:alert`
index.html
```
<html xmlns:x>
<head>
    <title></title>
    <style>
        x\:alert{
            behavior: url(x-alert.htc);
        }
    </style>
</head>
<body>
    <x:alert id="a" heading="Hello world!"></x:alert>    
    <script language="JScript">
        var a = document.getElementById('a')
        a.onheadingchange = function(){
            alert(event.propertyName + ':' + a.heading)
        } 
        // a.show()
        // a.close()
        // document.body.appendChilid(document.createElement('x:alert'))
    </script>
</body>
</html>
```
### 感受
&emsp;在写HTC时我有种写C的感觉，先通过HTC独有标签声明事件、属性、方法等，然后通过JScript来提供具体实现，其实写Angular2时也有这样的感觉，不过这里的感觉更强烈一些。
这里先列出开发时HTC给我惊喜的地方吧！
1. htc文件内的JScript代码作用域为htc文件本身，并不污染html文件的脚本上下文;
2. 带属性访问器的自定义属性大大提高我们对自定义属性的可控性;

然后就是槽点了
1. htc行为与元素绑定分离，好处是灵活，缺点是非自包含，每次引入都要应用者自己绑定一次太啰嗦了。我觉得Angular通过属性E绑定元素既灵活又实现自包含才是正路啊！
2. API有bug。如ondocumentready事件说好了是html文档加载完就会触发，按理只会触发一下，可实际上它总会在oncontentready事件后触发，还有fireEvent的API根本就没有，只能说继承了IE一如既往的各种坑。
3. 通过runtimeStyle来设置inline style，从而会丢失继承、层叠等CSS特性的好处;
4. 自定义元素内部结构会受到外部JS、CSS的影响，并不是一个真正闭合的元素。

## 总结
&emsp;很抱歉本文的内容十分对不住标题所述，更全面的观点请查看@徐飞老师的[从HTML Components的衰落看Web Components的危机](https://github.com/xufei/blog/issues/3)。假如单独看Custom Element，其实它跟HTML Component无异，都没有完整的解决自定义元素/组件的问题，但WebComponent除了Custom Element，还有另外3个好伙伴(Shadow DOM,template,html import)来一起为自定义元素提供完整的解决方案，其中Shadow DOM可谓是重中之重，后续继续研究研究:)
&emsp;尊重原创，转载请注明来自：^_^肥仔John

## 感谢
[从HTML Components的衰落看Web Components的危机](https://github.com/xufei/blog/issues/3)
[HTC Reference](https://msdn.microsoft.com/en-us/library/ms531018.aspx)
[Using HTML Components to Implement DHTML Behaviors in Script](https://msdn.microsoft.com/en-us/library/ms532146.aspx)
