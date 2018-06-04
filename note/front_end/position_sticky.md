```
position:
/* 全局值 */
inherit
initial
unset
/* 特有值 */
static
relative
absolute
fixed
sticky
```

特性：
1. 盒子位于文档流，原来占用的位置被保留
2. 相对偏移量是以最近一个`overflow`不为`visible`的祖先元素为参考系;若没有则以Visual Viewport为参考系
3. 不会创建新的BFC
4. 元素切换到fixed状态时，位移范围限制在父元素内

position:sticky
分为两个状态

默认状态行为是position:static
切换状态后与position:fixed相同，除了盒子依旧在normal flow之外。

状态切换条件：
top,right,bottom或left满足条件即触发
如top:20px时，那么当元素的border-box离Visual Viewport小于等于20px时则触发状态转换。


注意点：
1. 祖先元素中存在overflow/overflow-x/overflow-y不为visible时，position:sticky会失效
2. IOS中display:inline-block时，position:sticky会失效
3. 祖先元素中存在position:fixed时，现象会十分奇怪如下效果又有不同
```
.p {
  position: fixed;
}
.p .c{
  position: fixed;
}
```
4. 对于thead,tr,td无效


库
https://github.com/dollarshaveclub/stickybits


```

var next = el => () => el = el.parentNode
var pred = el => {
						const styles = window.getComputedStyle(el)
						return ['overflow', 'overflow-y', 'overflow-x']
							.reduce((accu, prop)=>{
									accu = accu || styles[prop] != 'visible'
								}
								, false)
					}

var some = (next, pred) => {
					const curr = next()
					if (curr == undefined || pred(curr)){
						return curr
					}
					return some(next, pred)
				 }
```
