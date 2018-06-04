KeyboardEvent
```
@prop {Boolean} altKey - 是否按了Alt(或OS X的Option)键
@prop {Boolean} ctrlKey - 是否按了Ctrl键
@prop {Boolean} shiftKey - 是否按了Shift键
@prop {Boolean} metaKey - 是否按了Meta键(OSX就是花Command按键，Windows就是田按键)
@prop {Boolean} isComposing - 当前事件发生在compositionstart和compositionend之间时
@prop {DOMString} code - 可打印字符，回车键返回Enter，ctrl返回ControlLeft或ControlRight，字符A返回KeyA，字符a返回KeyA，F1-12返回F1-12，主键盘的1返回Digit1
@prop {DOMString} key - 代替charCode，回车键返回Enter，ctrl返回Control而已，字符A返回A，字符a返回a，F1-12返回F1-12，主键盘的1返回1
@prop @deprecated {Number} keyCode - 键码ASCII,现已被key属性取代
@prop @deprecated {Number} which - unicode 编码,现已被key属性取代
@prop @deprecated {DOMString} charCode - 字符编码，可打印字符的Unicode编码，只有keypress时能获取有效值，keydown和keyup恒返回0。现已被key属性取代。
@prop {Number} location - 按键位于键盘或其他输入设置的位置索引
@prop {Boolean} repeat - 按住该键，持续响应。有时即使持续按住，但还是不被认为是按住该键触发的。
@method getModifierState():Boolean - 是否按住ctrl,alt,shift或meta键再按其他键
```
顺序
keydown -> keypress -> keyup
如果按键不是modifier key，则触发keypress

对于触发指示灯的按键，在Windows和Linux中仅触发keydown和keyup事件
而Mac OS X则只会触发keydown
然而各个浏览器都不相同

keypress不能拦截除Enter外的功能键，因此不支持组合键（如`ctrl`+`r`)
keypress中keycode,which,charCode中分大小写
keydown, keyup中keycode,which部分大小写
keydown,keyup可以拦截功能键
keydown无法拦截PrtSc截屏键
keyup可以拦截PrtSc截屏键，和截屏后通过Esc丢弃截屏结果

keypress 可以识别`shift`+`1`等获取的字符的! ascii码，而keydown和keyup则只能获取主键盘的数字对应的ascii码
keypress 无法识别主键盘和小键盘的数字
keydown和keyup可识别

键分类：字符键（可打印, printable key），功能键（不可打印）
功能键
Esc、Tab、Caps Lock、Shift、Ctrl、Alt、Enter、Backspace、Print Screen、Scroll Lock、Pause Break、Insert、Delete、Home、End、Page Up、Page Down， F1 through F12，Num Lock、The Arrow Keys

功能键的子类modifier key，包含Ctrl,Alt,Shift,Windows key. OS X Option, Command ,Control, Shift.就是要结合其他键一起用的键.笔记本的Fn也是

按住不放触发的事件是(Auto-repeat handling)
keydown
keypress
keydown
keypress
.......
keyup

而不断按(press repeatedly)
keydown
keypress
keyup
keydown
keypress
keyup
.......
keyup

而在有些GTK-based的环境Auto-repeat handling的事件发生顺序与press repeatedly是一样的，导致无法区分两者

组合键, ctrl+r
keydown of ctrl
keydown of r
然后刷新页面

ctrl+f
keydown of ctrl
keydown of f
然后弹出搜索框

因此ctrl+r和ctrl+f可以通过keydown事件的e.preventDefault()来阻止默认行为

而ctrl+t，ctrl+n, ctrl+w
只截取到keydown of ctrl，因此无法阻止默认行为

ctrl+alt+delete
```
```

中文输入法
禁用
```IE,firefox
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
或
<script>
;; 输入法时，keydown的keyCode和which均为229，key为Unidentified。而keyup则指向实际按的字符。keypress不被触发。
function diableIME(el){
	el.addEventListener('keydown', function(e){
		if (299 === e.keyCode){
			e.preventDefault()
			return e.returnValue = false
		}
		return true
	})
}
</script>
;; 输入法时，enter和shift仅触发keydown不会触发keyup，而keyCode为229
```


## REF
https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
http://www.cnblogs.com/manongxiaobing/archive/2012/11/05/2755412.html
http://unixpapa.com/js/key.html
