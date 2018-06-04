# 动手写个数字输入框3：痛点——输入法是个魔鬼
## 前言
&emsp;最近在用Polymer封装纯数字的输入框，开发过程中发现不是坑，也有不少值得研究的地方。本系列打算分4篇来叙述这段可歌可泣的踩坑经历：
1. 《动手写个数字输入框1：input[type=number]的遗憾》
2. 《动手写个数字输入框2：起手式——拦截非法字符》
3. 《动手写个数字输入框3：痛点——输入法是个魔鬼》
4. 《动手写个数字输入框4：魔鬼在细节——打磨光标位置》


## IE的先进性
&emsp;辛辛苦苦终于控制只能输入数字了，但只要用户启用了输入法就轻松突破我们的重重包围:-<心碎得一地都是。这是我们会想到底有没有一个API可以禁用输入法呢？答案是有的，但出人意料的是只有IE才支持。
```
<style>
	.disabled-ime-mode{
	  /*ime-mode为CSS3规则
		 *取值
		 *auto: 不影响IME的状态，默认值
		 *normal: 正常的IME状态
		 *active: 激活本地语言输入法
		 *inactive: 激活非本地语言输入法
		 *disabled: 禁用IME
		 */
		ime-mode: disabled;
	}
</style>
```
&emsp;而其他浏览器就呵呵了。。。

## 别无他法只能补救～
&emsp;由于chrome、firefox等无法通过样式`ime-mode`来处理，因此想到依葫芦画瓢，同样在keydown事件中对特定的keyCode进行拦截过滤就好了，谁知道在输入法中按下字符键时keydown事件的keyCode永远是229。其规律为：
1. 按字符键时，keydown中keyCode恒为229，且key为Undefined;而keyup中才会得到正确的keyCode，且key为正确的字符。
2. 按`enter`和`shift`时仅触发keydown不会触发keyup，而keyCode为229。
因此我们能做的是
1. 通过keyup事件作事后补救措施；
2. 在keydown中拦截输入法中输入的`enter`和`shift`按键事件，然后自行出发keyup事件执行补救措施。
废话少讲，上代码！
```
const keyCode = anyPass(prop('keyCode'), prop('which'))
const isBackspace = eq(8)
		, isDelete = eq(46)
		, isArrowLeft = eq(37)
		, isArrowRight = eq(38)
		, isArrowUp = eq(39)
		, isArrowDown = eq(40)
		, isTab = eq(9)
		, isHome = eq(36)
		, isEnd = eq(35)
const isValidStr = precision =>
									 a => RegExp("^[+-]?[0-9]*"+ (precision ? "(\\.[0-9]{0," + precision + "})?" : "") + "$").test(a)

// 获取min,max,precision值
const lensTarget = lens(a => a.target || a.srcElement)
		, lensMin = lens(a => Number(a.min) || Number(attr(a, 'min')) || Number.MIN_SAFE_INTEGER)
		, lensMax = lens(a => Number(a.max) || Number(attr(a, 'max')) || Number.MAX_SAFE_INTEGER)
		, lensPrecision = lens(a => Number(a.precision) || Number(attr(a, 'precision')) || 0)
		, lensValue = lens(a => a.value, (o, v) => o.value = v)
		, lensDataValue = lens(a => a && a.getAttribute('data-value'), (a, v) => a && a.setAttribute('data-value', v))

const lensTargetMin = lcomp(lensTarget, lensMin)
		, lensTargetMax = lcomp(lensTarget, lensMax)
		, lensTargetPrecision = lcomp(lensTarget, lensPrecision)
		, lensTargetValue = lcomp(lensTarget, lensValue)

const isIME = eq(229)
const isValidChar = c => /[-+0-9.]/.test(c)
const invalid2Empty = c => isValidChar(c) ? c : ''
const recoverValue = v => flatMap(CharSequence(v), invalid2Empty)

// 是否激活IME
const isInIME = comp(isIME, keyCode)
// 是否为功能键
		, isFnKey = comp(anyPass(isArrowLeft, isArrowRight, isArrowUp, isArrowDown, isBackspace, isDelete, isHome, isEnd), keyCode)

$('input[type=text]').addEventListener('keydown', e => {
	var el = view(lensTarget)(e)
		, val = view(lensTargetValue)(e)
	// 暂存value值，keyup时发现问题可以恢复出厂设置
	set(lensDataValue)(el)(val)

	if (isInIME(e)){
		fireKeyup(el)
	}
})
$('input[type=text]').addEventListener('keyup', e => {
	if (isFnKey(e)) return

	var el = view(lensTarget)(e)
		, v = view(lensValue)(el)
		, p = view(lensTargetPrecision)(e)
		, isValid = isValidStr(p)
		, max = view(lensMax)(el)
		, min = view(lensMin)(el)

	var val = recoverValue(v)
	var setVal = set(lensValue)(el)
	if (isValid(val)){
		if (val !== v){
			setVal(val)
		}
		else{
			var n = Number(v)
			if (!gte(max)(n)){
				setVal(max)
			}
			if (!lte(min)(n)){
				setVal(min)
			}
		}
	}
	else{
		setVal(attr(el, 'data-value'))
	}
})
```
## 附录：工具函数
```
// 工具函数，请无视我吧:D
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
						, times = Number(args[0]) || 1
						, ret = []
					while (times--){
						var tmpRet
						try{
							tmpRet = o[m].apply(o, args4m)
						}
						catch(e){
							tmpRet = void 0
						}
						ret.push(tmpRet)
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
const and = (...args) => args.reduce((accu, x) => accu && x, true)
const or = (...args) => args.reduce((accu, x) => accu || x, false)
const allPass = (...fns) => v => fns.reduce((accu, x) => accu && x(v), true)
const anyPass = (...fns) => v => fns.reduce((accu, x) => accu || x(v), false)
const eq = a => b => a === b
const gt = a => b => a > b
const gte = a => anyPass(eq(a), gt(a))
const lt = a => b => a < b
const lte = a => anyPass(eq(a), lt(a))
const prop = k => o => o[k]
const lens = (g, s) => ({getter: g, setter: s})
const lensPath = (...args) => ({ getter: a => args.reduce((accu, x) => accu && accu[x], a) })
const lcomp = (...lenses) => lenses
const view = lenses => a => {
	if (!~Object.prototype.toString.call(lenses).indexOf('Array')){
		lenses = [lenses]
	}
	return lenses.reduce((accu, lens) => accu && lens.getter(accu), a)
}
const set = lenses => a => v => {
	if (!~Object.prototype.toString.call(lenses).indexOf('Array')){
		lenses = [lenses]
	}
	var setLens = lenses.pop()
	var o = view(lenses)(a)
	if (o){
		setLens.setter(o, v)
	}
}

const $ = invoker(1, document, "querySelector")
const attr = (o, a) => invoker(1, o, 'getAttribute')(a)
const flatMap = (functor, f) => {
	return functor.flatMap(f)
}
function CharSequence(v){
	if (this instanceof CharSequence);else return new CharSequence(v)
	this.v = v
}
CharSequence.prototype.flatMap = function(f){
	return this.v.split('').map(f).join('')
}

const fireKeyup = (el) => {
	if (KeyboardEvent){
		// DOM3
		var e = new KeyboardEvent('keyup')
		el.dispatchEvent(e)
	}
	else{
		// DOM2
		var e = document.createEvent('KeyboardEvent')
		e.initEvent('keyup', true, true)
		el.dispatchEvent(e)
	}
}
```
## 未完待续
&emsp;到这里我们已经成功地控制了IME下的输入，虽然事后补救导致用户输入出现闪烁的现象:D那是不是就over了呢？当然不是啦。
用户输入时，光标位置是随机的，于是遗留以下问题:
1. 在keydow中预判断值合法性时，是假定光标位置处于行尾，将导致预判失误;
2. 在keyup中对value重新赋值时会导致光标移动到行尾，严重中断了用户的输入流程;
3. `type=text`会导致在移动端无法自动显示数字键盘。

## 总结
&emsp;后面我们会针对上述问题继续探讨，敬请留意！
