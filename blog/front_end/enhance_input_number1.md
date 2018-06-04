# 动手写个数字输入框1：input[type=number]的遗憾
## 前言
&emsp;最近在用Polymer封装纯数字的输入框，开发过程中发现不是坑，也有不少值得研究的地方。本系列打算分4篇来叙述这段可歌可泣的踩坑经历：
1. 《动手写个数字输入框1：input[type=number]的遗憾》
2. 《动手写个数字输入框2：起手式——拦截非法字符》
3. 《动手写个数字输入框3：痛点——输入法是个魔鬼》
4. 《动手写个数字输入框4：魔鬼在细节——打磨光标位置》

## HTML5带来的福利-`input[type=number]`
```
<input
	id="age" name="age"
	type="number" step="1" min="0" max="120">
<input
	id="inc"
	type="button" value="增加">
<input
	id="dec"
	type="button" value="减少">

<script>
	/* 工具函数...忽略我吧:D */
	const comp =
							(...fns) =>
							(...args) => {
								let len = fns.length
								while (len--){
									args = [fns[len].apply(null, args)]
								}
								return args.length > 1 ? args : args[0]
							}
	const isSome = x => 'undefined' !== typeof x && x !== null
	const invokerImpl =
									n =>
									o =>
									m =>
									(...args) => {
										let args4m = args.splice(0, n)
											, times = parseInt(args[0]) || 1
											, ret = []
										while (times--){
											ret.push(o[m].apply(o, args4m))
										}
										return ret.length > 1 ? ret : ret[0]
									}
	const curry2Partial =
		fn =>
		(...args) => {
			let c = true
				, i = 0
				, l = args.length
				, f = fn
			for (;c && i < l; ++i){
				c = isSome(args[i])
				if (c){
					f = f(args[i])
				}
			}
			return f
		}

	const invoker = curry2Partial(invokerImpl)
	const invoker0 = invoker(0)
	const $ = invoker(1, document, "querySelectorAll")
	const invoker0AtEl = comp(invoker0, $)

	/* 继续忽略我吧:D */
	const invoker0AtAge = invoker0AtEl('#age')

	// input[type=number]提供stepUp和stepDown两个方法来增加和减少数字
	const incAge = invoker0AtAge('stepUp')
			, decAge = invoker0AtAge('stepDown')
	$('#inc').addEventListener('click', incAge)
	$('#dec').addEventListener('click', decAge)
</script>
```
&emsp;`input[type=number]`为我们提供了如下特性：
1. 限制只能输入`[+-0-9.]`这几个字符
2. 输入法(IME)也无法输入非`[+-0-9.]`的字符
3. 自动的表单验证
4. `min`和`max`来限制数值的下限和上限;
5. 提供stepUp和stepDown两个方法实现以编程方式控制数值的增加和减少;
6. 移动设备上当它获得焦点时，会出现数字键盘;
7. `step`设置点击右侧微调按钮的步长(默认为1)，可设置为小数、整数或`any`。`step`的值除了影响微调按钮的步长外，还影响表单验证信息。
```
<!-- step为整数时 -->
<input name="age1" type="number"
	step="1" value="1">
<input name="age1" type="number"
	step="1" value="1.1">

<!-- step为小数时 -->
<input name="age2" type="number"
	step="0.1" value="1">
<input name="age2" type="number"
	step="0.1" value="1.1">
<input name="age2" type="number"
	step="0.1" value="1.11">

<!-- step为any时 -->
<input name="age3" type="number"
	step="any" value="1">
<input name="age3" type="number"
	step="any" value="1.1">
<input name="age3" type="number"
	step="any" value="1.11">

<script>
  // 显示 true false
	$('[name=age1]').forEach(el => console.log(el.validity.valid))
  // 显示 true true false
	$('[name=age2]').forEach(el => console.log(el.validity.valid))
  // 显示 true true true
	$('[name=age3]').forEach(el => console.log(el.validity.valid))
</script>
```
另外，设置为any是让表单验证不受精度限制而已，实际上步长依然为1。

## 遗憾了我的哥
&emsp;到这里我想大家都会发现怎么少了个精度设置呢？确实，`input[type=number]`并没有为我们提供设置精度的属性或方法。但遗憾的何止是这个呢？
1. 木有精度精度设置;
2. 不想要右侧的微调按钮还不行了...
3. 点击微调按钮和调用`stepUp`和`stepDown`设置数值确实被限制在`min`和`max`区间，但直接输入却不受限制...
4. 可以输入多个小数点，如`2012.12.12`;
5. 设置`step=any`后，chrome on android的数字键盘居然没了小数点按键。
6. 设置`step=any`后，点击微调按钮步长为1，但调用`stepUp`和`stepDown`则报
```
Uncaught DOMException: Failed to execute 'stepUp' on 'HTMLInputElement': This form element does not have an allowed value step.
```

## 隐藏右侧微调按钮不完全解决方法
Webkit和Gecko下可通过以下的CSS来隐藏右侧微调按钮
```
/* chrome */
input[type=number]::-webkit-outer-spin-button,
input[type=number]::-webkit-inner-spin-button{
	-webkit-appearance: none!important;
	margin: 0;
}
/* Firefox */
input[type=number]{
	-moz-appearance: textfield;
}
```
IE就没辙了:-(

## 总结
&emsp;也许你会问既然HTML5愿意为我们新增一个全新的`input[type=number]`，为什么偏偏提供一个缺胳膊少腿的呢？只能说得哥情时失嫂意，既然它不满足，那就自己写写看咯:)
