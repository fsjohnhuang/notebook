# 只允许输入数字

## input[type=number]
```
<style>

/* 不显示上下选择按钮 */
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
</style>
<input type="number">
```

## 支持selectionStart,selectionEnd和setSelectionRange(), select()的元素
```
input[text|search|password|tel|url]
```
对于
```
input[number]
```
若要控制光标位置，则要将type改为text或tel(tel的话，对于移动端会显示numeric keyboard)，然后附加js控制
已有的库为
http://digitalbush.com/projects/masked-input-plugin/
http://jherax.github.io/#jqueryfnnumericinput-
http://firstopinion.github.io/formatter.js/

对于支持的元素获取光标当前位置
```
;; 通过window.getSelection()获取获取全局选中对象，然后不断扩展选中对象直到无法扩展，则能获取当前光标的位置
(defn get-caret-pos-by-selection
	[el l]
	(let [s (js/window.getSelection)]
		(.modify s "extend" "backword" "character")
		(let [nl (max l (.. s toString -length))]
			(if (not= l nl) (get-caret-pos-trick el nl) nl))))
(defn rollback-caret
	[el l]
	(let [s (js/window.getSelection)]
		(dotimes [n l]
			(.modify s "extend" "forward"))))
(defn get-caret-pos-trick
	[el]
	(let [l (get-caret-pos-by-selection el 0)]
		(rollback-caret l)
		l))

(defn get-caret-pos
  [el]
	(let [start (.-selectionStart el)]
  (cond
	  ;; for IE9+
    (some? start) start
		;; for element type=number and so on which is not support selectionStart,selectionEnd and setSelectionRange
		(nil? start)
		(get-caret-pos-trick el)
    ;; below IE9
		(some? js/document.selection)
		(let [sel (js/document.selection.createRange)]
			(.moveStart sel "character" (.. el -value -length))
			(.. sel -text -length))
		;; default
		:else -1)))
    
```

inputMode = "number" or "email“， for sake of any mobile browsers support adjusting the IME for those input type.

```
// 获取当前激活的元素
document.activeElement
// 获取当前Selection实例
const selection = document.getSelection() 或 window.getSelection()
// 删除当前选中区域
selection.deleteFromDocument()
// 获取选中内容的字符长度
String(selection).length
// 对选中区域作处理
// @param {String} alter - the type of change to apply. 
//												 "move" to move the current cursor position
//												 "extend" to extend the current selection.
// @param {String} direction - the direction in which to adjust the current position. "forward" and "backward" based on the language at the selection point. "left" and "right" to adjust in a specific direction.
// @param {String} granularity - the distance to adjust the current selection or cursor position.
// "character", "word", "sentence", "line", "paragraph", "lineboundary","sentenceboundary", "paragraphboundary", "documentboundary"
selection.modify(alter, direction, granularity)

selection.collapseToEnd()
```

选中部分文本
```
(defn set-selection-range
	[input start end]
	(cond
		;; 直接使用setSelectionRange方法
		(fn? (.-setSelectionRange input))
		(.setSelectionRange input start end)
		;; 间接
		(some? (.-selectionStart input))
		(do
			(set! (.-selectionStart input) start)
			(set! (.-selectionEnd input) end)
			(.focus input))
		;; IE678，以下API，IE9，10，11都有
		:else
		(let [text-range (.createTextRange input)]
			(.moveStart text-range "character" start)
			(.moveEnd text-range "character" end)
			(.select text-range))))
```
获取选中的文本
```
(defn get-selection-range
	([] (get-selection-range js/document.activeElement))
	([input]
		(cond
			(some? (.-selectionStart input))
			(subs (.-value input)
				(.-selectionStart input) (.-selectionEnd input))
			;; IE
			(fn? (.-createTextRange input))
			(.. input createTextRange -text)
			;; input[type=number]
			:else
			(do
				(.focus input)
				(str (js/document.getSelection))))))
```

selectionEnd supported from IE9

below IE9
document.createRange():Range - 获取文档的selection
HTMLInputElement.createTextRange:TextRange - 
HTMLInputElement.createControlRange:ControlRange - 
document.selection:MSSelection


IDL attribute
get value of an input of type=number
```
valueAsNumber - returns the number corresponding to the input, or NaN if the input is invalid.
value - returns the input as text, or the empty string if the input is invalid.
```
valueAsDate


## Range接口
represents a fragment of a document that can contain nodes and parts of text nodes.

3种Range:
W3C Range
Mozilla Selection - 就是Selection对象
Microsoft TextRange - IE6/7
```
(.. js/document -selection createRange)
```

W3C Range
创建或获取方式
```
;; 创建一个边界位于当前document最开头的位置的Range实例
;; 且该Range实例的边界仅能设置位于当前document内，或ownerDocument属性为当前document的DocumentFragment或Attr实例上。
;; (Ref)[https://www.w3.org/TR/DOM-Level-2-Traversal-Range/ranges.html#Level2-DocumentRange-method-createRange]
(js/document.createRange)

;; returns a range object representing one of the ranges currently selected
;; @param index - in the range of Selection.rangeCount
(.getRangeAt selection-inst
	index)

;; returns a range object for the document fragment under the specified coorinates.
;; @param {Number} x - a horizontal position within the current viewport
;; @param {Number} y - a vertical position within the current viewport
;; @returns {Range} return null, when x or y is negative, outside viewport, or there is no text entry node
(js/document.caretRangeFromPoint x y)

new Range()
```

在选中位置插入元素
```
;; 将新元素插入到选中的位置
(defn insert!
	[text-node offset inserting-el]
	(-> text-node
		.-parentNode
		(.insertBefore inserting-el ((.splitText text-node)))))

;; 获取选中的元素和在该元素中的位移
(defn get-node-offset
	[x y]
	(if (fn? (.-caretPositionFromPoint js/document))
		(let [range (.caretPositionFromPoint js/document x y)]
			[(.-offsetNode range) (.-offset range)])
		(let [range (.caretRangeFromPoint js/document x y)]
			[(.-startContainer range) (.-startOffset range)])))

(defn handler
	[e]
	(apply
		insert!
		(conj
			(get-node-offset (.-clientX e) (.-clientY e))
			(js/document.createElement "br"))))

(js/document.addEventListener "click" handler)
```

实例属性(read only all)
```
;; Boolean, 起始和结尾位于同一个位置
(.-collapsed range-inst)

;; Node，返回最近一个包含startContainer和endContainer的元素
(.-commonAncestorContainer range-inst)

;; Node, range头所在的元素
(.-startContainer range-inst)
;; Number, range头所在元素中具体起始位置 
(.-startOffset range-inst)

;; Node, range结尾所在的元素
(.-endContainer range-inst)
;; Number, range尾所在元素中具体结束位置 
(.-endOffset range-inst)
```
实例方法
```
;; 设置range的起始元素和起始位置
(.setStart range-inst
	start-node
	start-offset)

;; 设置range的结束元素和结束位置
(.setEnd range-inst
	end-node
	end-offset)

;; 将range头设置在reference-node之前
(.setStartBefore range-inst reference-node)

;; 将range头设置在reference-node之后
(.setStartAfter range-inst reference-node)

;; 将range尾设置在reference-node之前
(.setEndBefore range-inst reference-node)

;; 将range尾设置在reference-node之后
(.setEndAfter range-inst reference-node)

;; 将range设置为包含reference-node及其内容
(.selectNode range-inst reference-node)

;; 将range设置为包含reference-node下的内容
(.selectNodeContents range-inst reference-node)

;; 折叠range到其中一端，to-start默认为ture，表示折叠到头一端
(.collapse range-inst to-start)

;; 复制range中包含的Node，通过addEventListener等方式订阅的事件不被复制，但通过DOM0方式方式(onclick)的则会被复制
;; @returns DocumentFragment
(.cloneContents range-inst)

;; 深度复制
;; @returns Range
(.cloneRange range-inst)

;; 删除range中包含的内容连container一起删除，但不会返回被删除的DocumentFragment
(.deleteContents range-inst)

;; 将range中包含的内容连container一起剪切，并返回DocumentFragment.通过addEventListener等方式订阅的事件不被剪切，但通过DOM0方式方式(onclick)的则会被剪切
(.extractContents range-inst)

;; 将new-node插入到range的起始端
(.insertNode range-inst new-node)

;; 将range的内容作为子元素追加到new-node中，然后将range的范围扩展到new-node上。
(.surrondContents range-inst new-node)

;; 比较range-inst 和 source-range的边界点
;; @param how - Range.END_TO_END , Range.END_TO_START, Range.START_TO_END, Range.START_TO_START
;; @returns {Number} -1, 0, 1 表示 先于，等于和后于
(.compareBoundaryPoints range-inst how source-range)

;; 比较reference-node是否先于(-1)、等于(0)或后于(1)range，若reference-node是Text,Comment或CDATASection，那么offset为字符索引，否则就是reference-node子元素索引
(.comparePoint range-inst reference-node offset)

;; 释放range所占的资源，对已释放资源的range调用该方法会报DOMException error code of INVALID_STATE_ERR
(.detach range-inst)

;; 返回range内容的文本
(.toString range-inst)

;; 将tag-string解析实例化为html判断
;; @param {String} tag-string
;; @return {DocumentFragment}
(.createContextualFragment range-inst tag-string)
;; 示例
(let [tag-string "<div>I'm a div node</div>"
			range (js/document.createRange)]
	(js/document.body.appendChild
		(.createContextualFragment range tag-string)))

;; 判断reference-node有一部分在range中
;; @returns {Boolean}
(.intersectsNode range-inst reference-node)

;; 判断reference-node指定部分开始是否在range中
;; @returns {Boolean}
(.isPointInRange range-inst reference-node offset)

;; 获取包含range内容的ClientRect实例,对于DOMRect要参考Element.getBoundingClientRect()
(.getBoundingClientRect range-inst)

;; 返回range下所有子元素的ClientRect组成的ClientRectList
(.getClientRects range-inst)
```

## Selection类
Selection实例代表文本选择的range或当前光标的位置，当为文本选择时，type为Range；当为光标位置时，type为Caret。
一个selection实例代表多个用户选择的ranges实例，一般情况下同时只有一个range实例
```
;; 得到Selection实例
(js/window.getSelection)
```

```
anchorNode
anchorOffset
baseNode
baseOffset
extentNode
extentOffset
focusNode
focusOffset
isCollapsed
rangeCount
type - 值Caret
```

方法
```
;; 将Mozilla Selection转换为W3C Range
(.getRangeAt selection-inst index)

;; 选中range-inst
(.addRange range-inst)
```

document.designMode = 'off'或'on'，设置整个文档是否可编辑。

### ref
https://stackoverflow.com/questions/21177489/selectionstart-selectionend-on-input-type-number-no-longer-allowed-in-chrome
https://stackoverflow.com/questions/22381837/how-to-overcome-whatwg-w3c-chrome-version-33-0-1750-146-regression-bug-with-i/24247942#24247942
http://pchalin.blogspot.com/2014/02/html5-number-input-value-idl-attribute.html
http://help.dottoro.com/ljtfkhio.php
https://developer.mozilla.org/en-US/docs/Web/API/Selection/modify
https://stackoverflow.com/questions/12354918/what-does-idl-attribute-mean-in-the-whatwg-html5-standard-document
https://bugs.chromium.org/p/chromium/issues/detail?id=32436
https://developer.mozilla.org/en-US/docs/Web/API/Selection
https://developer.mozilla.org/en-US/docs/Web/API/Range
http://www.zhangxinxu.com/wordpress/2011/04/js-range-html%E6%96%87%E6%A1%A3%E6%96%87%E5%AD%97%E5%86%85%E5%AE%B9%E9%80%89%E4%B8%AD%E3%80%81%E5%BA%93%E5%8F%8A%E5%BA%94%E7%94%A8%E4%BB%8B%E7%BB%8D/

Web IDL: https://heycam.github.io/webidl/
```
<div id="a" class="A"></div>
<script>
	const a = document.querySelector('#a')
	a.className = 'B'
</script>
```
`id`和`class`是content attribute,而`className`就是IDL attribute。
IDL-interface definition language，Web IDL是IDL的变形，用于定义script object接口，通常以属性的方式访问和操作。
有些Content Attribute会和IDL Attribute实时同步，而有的则不会


autocomplete适用于`form`,`[type=text]`,`[type=search]`,`[type=tel]`,`[type=url]`,`[type=email]`,`[type=password]`,`[type=datepicker]`,`[type=range]`,`[type=color]`
默认情况下IE会启用自动完成功能
若禁止某个表单元素的AutoComplete，就`<input type="text" autocomplete="off">`
若禁止某表单下所有元素的AutoComplete，就`<form autocomplete="off"></form>`


