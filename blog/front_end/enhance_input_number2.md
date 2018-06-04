# 动手写个数字输入框2：起手式——拦截非法字符
## 前言
&emsp;最近在用Polymer封装纯数字的输入框，开发过程中发现不是坑，也有不少值得研究的地方。本系列打算分4篇来叙述这段可歌可泣的踩坑经历：
1. 《动手写个数字输入框1：input[type=number]的遗憾》
2. 《动手写个数字输入框2：起手式——拦截非法字符》
3. 《动手写个数字输入框3：痛点——输入法是个魔鬼》
4. 《动手写个数字输入框4：魔鬼在细节——打磨光标位置》

## 从源头抓起——拦截非法字符 &emsp;从《动手写个数字输入框1：input[type=number]的遗憾》中我们了解到`input[type=number]`基本不能满足我们的需求，为了简单化我们就直接在`input[type=text]`上加工出自己的数字输入框吧。
&emsp;首先很明确的一点是最终数值可以包含以下字符`[+-0-9.]`，而可输入的功能键为`Backspace`,`Delete`,`Arrow-Left`,`Arrow-Right`,`Arrow-Up`,`Arrow-Down`和`Tab`。
于是我们可以设置如下规则了
```
// 断言库
const keyCode = anyPass(prop('keyCode'), prop('which'))
const isBackspace = eq(8)
		, isDelete = eq(46)
		, isArrowLeft = eq(37)
		, isArrowRight = eq(38)
		, isArrowUp = eq(39)
		, isArrowDown = eq(40)
		, isTab = eq(9)
		, isMinus = anyPass(eq(109), eq(189))
		, isDot = anyPass(eq(110), eq(190))
		, isDigit = anyPass(
									allPass(lte(49), gte(57))
									, allPass(lte(96), gte(105)))
		, isPlus = anyPass(
								comp(eq(107), keyCode)
								, allPass(
										prop('shiftKey')
										, comp(eq(187), keyCode)))

const isValid  = anyPass(
									comp(
										anyPass(isBackspace, isDelete, isArrowLeft
											, isArrowLeft, isArrowUp, isArrowDown
											, isTab, isMinus, isDot, isDigit)
										, keyCode)
									, isPlus)

$('input[type=text]').addEventListener('keydown', e => {
	if (!isValid(e)){
		e.preventDefault()
	}
})
```

## 扩大非法字符集
&emsp;还记得min,max,precision吗？
1. 当min大于等于0时，负号应该被纳入非法字符；
2. 当max小于0时，正号应该被纳入非法字符；
3. 当precision为0时，小数点应该被纳入非法字符。于是我们添加如下规则，并修改一下`isValid`就好了
```
// 获取min,max,precision值
const lensTarget = lens(a => a.target || a.srcElement)
		, lensMin = lens(a => Number(a.min) || Number(attr(a, 'min')) || Number.MIN_SAFE_INTEGER)
		, lensMax = lens(a => Number(a.max) || Number(attr(a, 'max')) || Number.MAX_SAFE_INTEGER)
		, lensPrecision = lens(a => Number(a.precision) || Number(attr(a, 'precision')) || 0)
		, lensValue = lens(a => a.value)

const lensTargetMin = lcomp(lensTarget, lensMin)
		, lensTargetMax = lcomp(lensTarget, lensMax)
		, lensTargetPrecision = lcomp(lensTarget, lensPrecision)

const isValid  = anyPass(
									comp(
										anyPass(isBackspace, isDelete, isArrowLeft
											, isArrowLeft, isArrowUp, isArrowDown
											, isTab, isDigit)
										, keyCode)
									, allPass(
											comp(gt(0), view(lensTargetMin))
											, comp(isMinus, keyCode))
									, allPass(
											comp(lte(0), view(lensTargetMax))
											, isPlus)
									, allPass(
											comp(lt(0), view(lensTargetPrecision))
											, comp(isDot, keyCode)))
```

## 预判断
&emsp;到这里为止我们已经成功地拦截了各种非法字符，也就是最终值必须之含`[+-0-9.]`，但含这些字符跟整体符合数值格式就是两回事了。因此我们要继续补充下面两步，并且由于keydown事件触发时value值还没被修改，于是我们需要将value值和当前输入值做组合来做预判，进一步扩大非法字符集。
1. 通过正则检查最终值是否符合格式要求(是否存在多个小数点也会在这一步处理掉);
2. 检查最终值是否在`min`和`max`范围内。
```
const isValidStr = precision =>
									 a => RegExp("^[+-]?[0-9]*"+ (precision ? "(\\.[0-9]{0," + precision + "})?" : "") + "$").test(a)
const lensValue = lens(a => a.value)
	  , lensTargetValue = lcomp(lensTarget, lensValue)

$('input[type=text]').addEventListener('keydown', e => {
	var prevented = true
	// 拦截非法字符
	if (isValid(e)){
		prevented = false

		// 预判断
		if (anyPass(comp(anyPass(isMinus, isDigit, isDot), keyCode), isPlus)(e)){
			var str = view(lensTargetValue)(e) + prop('key')(e)
			// 预判断格式
			prevented = !isValidStr(view(lensTargetPrecision)(e))(str)

			// 预判断值范围
			if (!prevented){
				if (str == '-') str = '-0'
				if (str == '+') str = '0'
				if (str == '.') str = '0'

				prevented = !allPass(
											gte(view(lensTargetMax)(e))
											, lte(view(lensTargetMin)(e)))(Number(str))
			}
		}
	}

	if (prevented){
		e.preventDefault()
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
const lcomp = (...lenses) => ({ getter: a => lenses.reduce((accu, lens) => accu && lens.getter(accu), a)})
const view = l => a => l.getter(a)

const $ = invoker(1, document, "querySelector")
const attr = (o, a) => invoker(1, o, 'getAttribute')(a)
```

## 总结
&esmp;现在可以终于可以牢牢控制住用户输入了，直到用户切换到IME为止:-<当使用IME输入时会发现上述措施一点用也没有，不用皱眉了，后面我们会一起把IME KO掉！
