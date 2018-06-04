W3C Range，基于DOM tree
Mozilla Selection，基于DOM tree
IE TextRange，基于字符串

```
(defn get-user-selection
	"获取user selection"
	[]
	(if (fn? js/window.getSelection)
		; Mozilla Selection对象
		(js/window.getSelection)
		; IE的MSSelection对象
		(js/document.selection)))

(defn get-selection-text
	"获取选中的文本"
	[s]
	(if-some [ie-txt (.-text s)]
		; IE的TextRange的text属性
		ie-txt
		; Mozilla Selection对象的toString
		(.toString s)))

(defn get-range-from-selection
	"从Selection中获取Range"
	[s]
		(cond
			;; IE下获取TextRange
			(fn? (.-createRange s)) (.createRange s)
			;; W3C Compatible
			(fn? (.-getRangeAt s)) (.getRangeAt s 0)
			:else
			(let [r (js/document.createRange)]
				(.setStart r (.-anchorNode s) (.-anchorOffset s))
				(.setStart r (.-anchorNode s) (.-anchorOffset s))
				r)))
```

## MSSelection
```
;; @desc 获取MSSelection对象
;; @ts js/document.selection :: MSSelection

;;;; 方法

;;.clear :: MSSelection -> nil
;;.empty :: MSSelection -> nil

;; @desc 定义IE的Range类
type IERange = TextRange | ControlRange

;; @desc 若当前选中的是text selection则返回TextRange，若选中的是control selection则返回ControlRange
;; @refer https://msdn.microsoft.com/en-us/library/ms536394(v=vs.85).aspx
;; @ts .createRange :: (MSSelection s, IERange r) => s -> r

;; @desc 从当前用户选择中获取多个TextRange对象，IE5.5以下不支持
;; @ts .createRangeCollection :: (MSSelection s, TextRangeCollection ts) => s -> ts
```

## TextRange
```
;; @desc 获取选中的文本
;; @ts .-text :: TextRange -> String
```

## Selection
```
;; @desc 获取选中的文本
;; @ts .toString :: Selection -> String
```

## 从可编辑元素获取Range
```
;; @desc 返回的TextRange将包含整个可编辑元素的内容，而不是高亮选中的内容
;; @ts .createTextRange :: (Editable el) => el -> TextRange
```

```
;; @desc HTML5中获取selection的起始索引
;; @ts .-selectionStart :: Editable -> Int

;; @desc HTML5中获取selection的结束索引
;; @ts .-selectionEnd :: Editable -> Int

;; @desc HTML5中设置selection的起始和结束索引，会影响高亮选中的位置
;; @ts .setSelectionRange :: Editable -> Int start -> Int end -> Nil
```

## REF
https://www.quirksmode.org/dom/range_intro.html
