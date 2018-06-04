# 前端魔法堂：onsubmit和submit事件处理函数怎么不生效呢？
## 前言
&emsp;最近在用Polymer增强form，使其支持表单的异步提交，但发现明明订阅了onsubmit和submit事件，却怎么也触发不了。下面我们将一一道来。

## 提交表单的方式
1. 表单仅含一个以下的元素时，该元素得到焦点，按回车键，即可发起表单提交。
```
input[type=text]
input[type=password]
input[type=email]
input[type=url]
input[type=tel]
input[type=number]
input[type=search]
```
示例:
```
<form>
	<label for="name"></label>
	<input type="text" id="name" name="name">
	<select id="sex" name="sex">
		<option value="0">male</option>
		<option value="1">female</option>
	</select>
</form>
```
2. 表单含两个或以上的上述元素时，在表单中添加一个`input[type=submit]`子元素，或在表单外添加一个`input[type=submit form=表单ID]`的元素，那么当上述元素得到焦点，按回车键，即可发起表单提交。
示例:
```
<form>
	<label for="name"></label>
	<input type="text" id="name" name="name">
	<label for="age"></label>
	<input type="number" id="age" name="age" value="0">
	<input type="submit" value="submit">
</form>
```
3. 通过调用表单元素的`submit`方法。
示例:
```
<form>
	<label for="name"></label>
	<input type="text" id="name" name="name">
	<label for="age"></label>
	<input type="number" id="age" name="age" value="0">
	<input type="button" value="submit">
</form>
<script>
var btn = document.querySelector('input[type="button"]')
	, form = document.querySelector('form')
btn.addEventListener('click', function(e){
	form.submit()
})
</script>
```
4. 通过触发表单的submit事件
示例1, IE 678:
```
var form = document.querySelector('form')
form.fireEvent('onsubmit')
form.submit()
```
示例2，DOM Level 2 Event
```
var e = document.createEvent('HTMLEvents')
e.initEvent('submit', true, true)
var form = document.querySelector('form')
form.dispatchEvent(e)
```
示例3，DOM Level 3 Event
```
var e = new Event('submit')
var form = document.querySelector('form')
form.dispatchEvent(e)
```
示例4，jQuery
```
$('form').trigger('submit')
```

## 各种提交方式的背后
### 就onsubmit函数和submit事件而言
1. 方式1，方式2和方式4均可依次调用onsubmit函数和触发submit事件，因此可以在onsubmit函数或submit事件处理函数中禁止执行默认行为来实现表单的异步提交;
2. 方式3既不会调用onsubmit函数，也不会触发submit事件。

### 还有HTML5表单合法性验证呢！
&emsp;HTML5对表单作了增强，其中最耀眼的可谓是合法性验证这一部分。首先我们要明确一点的是，验证发生在与input等表单控件发生交互时(输入，点击，脚本修改其值等)，而不是提交表单时才触发验证。然后再根据表单的配置和触发表单提交的方式，决定合法性验证的结果似乎会阻止表单的提交。

前提：form.novalidate为false
```
<form>
	<input type="text" id="name" name="name" required>
</form>
```
1. 方式1和方式2，若`input#name`内容为空，则弹出非法内容警告，并阻止表单提交，不执行onsubmit和触发submit事件
2. 方式3，直接提交表单
3. 方式4，若`input#name`内容为空，不弹出非法内容警告，更不会阻止表单提交, 而是执行onsubmit和触发submit事件
因此要方式4实现与方式1,2的效果可以这样处理
```
var e = new Event('submit')
var form = document.querySelector('form')
form.addEventListener('submit', function(e){
	if (!form.novalidate && form.reportValidity()){
		e.preventDefault()
	}
})
form.dispatchEvent(e)
```
&emsp;到这里对表单提交的方式和不同方式引起后续不同的效果有了解，但不稍微深入上面引入关于合法性验证的内容心里总是发痒，下面我们继续挖一挖吧！

## 说说HTML5下的表单合法性验证
&emsp;说到合法性验证，那必须说到一个新增的类型ValidityState
```
@interface ValidityState
@description input等表单控件通过validity属性获取
@prop {Boolean} valid - 内容是否符合规定
@prop {Boolean} valueMissing - 是否违反必填约束
@prop {Boolean} typeMismatch - 是否违反类型约束,如type=url|email|number等约束
@prop {Boolean} badInput - 是否为无效输入(无法转换为目标类型)，如number输入了非数字
@prop {Boolean} tooLong - 是否超长
@prop {Boolean} tooShort - 是否长度不足
@prop {Boolean} stepMismatch - 是否符合step值设置的间隔
@prop {Boolean} rangeUnderflow - 是否小于最小值
@prop {Boolean} rangeOverflow - 是否大于最大值
@prop {Boolean} patternMismatch - 是否违反正则
@prop {Boolean} customError - 是否存在自定义错误信息
```
另外，表单控件还有其他属性、方法和事件是和合法性验证相关的
```
@prop {Boolean} willValidate - 是否启用合法性校验，只要设置了required等合法性验证属性即表示启用
@prop {String} validationMessage - 校验失败时的提示信息
@method setCustomValidity([{String} msg='']):undefined - 设置自定义错误信息，设置为undefined或空字符串，表示不存在自定义错误信息
@event invalid - 调用表单控件的checkValidity()或reportValidity()，非法时触发该事件

下面的方法，form和input等表单控件均拥有
@method checkValidity():Boolean - 检查是否符合校验约束，若不符合则触发相应的表单控件的invalid事件
	form.addEventListener('submit', function(){
		form.checkValidity()
	})
@method reportValidity():Boolean - 功能和checkValidity一样，但另外会以浏览器定义的方式显示提示信息
```

## 总结
&emsp;尊重原创，转载请注明来自：尊重原创，转载请注明来自：http://www.cnblogs.com/fsjohnhuang/p/6739064.html ^_^肥仔John
