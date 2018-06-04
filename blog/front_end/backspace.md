# 前端魔法堂：屏蔽Backspace导致页面回退
## 前言
&emsp;前几天用户反映在录入资料时一不小心错按Backspace键，就会直接回退到是一个页面，导致之前辛辛苦苦录入的资料全部丢失了。哦？居然还有这种情况。下面我们来一起探讨一下吧！

## Windows系统下独有的行为
&emsp;Windows下的IE、FireFox和Chrome 52之前的浏览器，当焦点不在一个可编辑的元素上时，按`Backspace`键就会回退到上一个页面，按`Shift`+`Backspace`键则会前进到下一个页面。
&emsp;而Chrome 52以后的浏览器则屏蔽了`Backspace`和`Shift`+`Backspace`的上述行为，而是采用`Alt`+`Left`实现回退和`Alt`+`Right`实现前进。如果想恢复`Backspace`回退，则需要安装Go Back With Backspace的Extension才行。
&emsp;对于FireFox而言，我们可以设置`Backspace`和`Shift`+`Backspace`的行为。
1. 在地址栏输入`about:config`
2. 在搜索框输入`browser.backspace_action`，然后设置项目值即可。有3个可选项
`0`，表示`Backspace`和`Shift`+`Backspace`的行为对应页面回退和前进(Windows下的默认值)
`1`，表示`Backspace`和`Shift`+`Backspace`的行为对应页面向下滚动和向上滚动
`2`或其他值，表示不响应`Backspace`和`Shift`+`Backspace`(Ubuntu16下的默认值)

注意：Linux和OS X下的浏览器按`Backspace`和`Shift`+`Backspace`不会触发页面的回退和前进。

## 如何应对
### 方案一：页面跳转时弹出二次确认
&emsp;通过`beforeunload`事件实现页面跳转时弹出二次确认模态窗，让用户有后悔的机会。但会截断其他正常跳转的操作流畅性，在确实没有办法时才使用！

### 方案二
&emsp;屏蔽`Backspace`和`Shift`+`Backspace`的默认行为，仅当焦点落在可编辑区域中时才暂时取消屏蔽。
那么哪些算是能获得焦点的可编辑区域呢？就下面这些咯！！
```
input[type=text]:not([readonly])
input[type=password]:not([readonly])
input[type=number]:not([readonly])
input[type=email]:not([readonly])
input[type=url]:not([readonly])
input[type=search]:not([readonly])
input[type=tel]:not([readonly])
textarea:not([readonly])
[contenteditable]:not([readonly])
```
就是说当焦点落在上述符合规则的元素上时，按`Backspace`和`Shift`+`Backspace`的默认行为就不是页面跳转，因此不用屏蔽掉。

## 附加功能
&emsp;现在我们的目的是页面不会因为用户误操作而刷新，导致页面数据丢失。这里有两个组合键同样会的导致页面刷新
1. `ctrl`+`r`刷新当前页面，可被阻止;
2. `ctrl`+`w`关闭当前窗体或标签页，无法阻止。

## 代码时间.js
```
	;window.nobsgb || (function(exports){
		var KEYCODE = {
			BACKSPACE: 8,
			R: 82
		}
		// 判断type是否不受阻止
		var isEscapableType = function(rEscapableTypes){
			return function(type){
				return rEscapableTypes.test(type)
			}
		}(/text|textarea|tel|email|number|search|password|url/i)
		// 判断标签是否不受阻止
		var isEscapableTag = function(rEscapableTag){
			return function(tag){
				return rEscapableTag.test(tag)
			}
		}(/input|textarea/i)
		// 判断是否设置为content editable
		var isContentEditable = function(el){
			return el.isContentEditable
		}
		// 判断是否为不受阻止的Backspace
		var isEscapableBackspace = function(el){
			return or(isEscapableTag(el.tagName)
					  && 
					  or(!('type' in el)
				         , ('type' in el) && isEscapableType(el.type) && !el.readOnly)
				      , isContentEditable(el))
		}
		var isCtrlR = function(e, keycode){
			return e.ctrlKey && KEYCODE.R === keycode
		}
		var isArray = function(x){
			return /Array/.test(Object.prototype.toString.call(x))
		}
		
		var getEvt = function(e){
			return e || window.event
		}
		var getTarget = function(e){
			return e.target || e.srcElement
		}
		var getKeycode = function(e){
			return e.keyCode || e.which
		}
		var preventDefault = function(e){
			e.preventDefault && e.preventDefault()
			e.returnValue = false
			return false
		}
		var listen = function(listen){
			return function(evtNames, handler){
				if (!isArray(evtNames)){
					evtNames = [evtName]
				}
				var i = 0
				  , len = evtNames.length
				for (; i < len; ++i){
					listen(evtNames[i], handler)
				}
			}
		}(function(evtName, handler){
			if (or(document['addEventListener'] && (document['addEventListener'].apply(document, arguments) || true)
			       , document['attachEvent'] && (document['attachEvent'].apply(document, arguments) || true))){
				document['on'+evtName] = handler
			}
			
		})
		
		var or = function(){
			var ret = false
			  , i = 0
			  , len = arguments.length
			for (; !ret && i < len; ++i){
				ret = ret || arguments[i]
			}
			return ret
		}
		var handler = function(e){
			var evt = getEvt(e)
			  , el = getTarget(evt)
			  , keyCode = getKeycode(evt)

			if (or(KEYCODE.BACKSPACE === keyCode && !isEscapableBackspace(el)
				  , isCtrlR(evt, keyCode))){
				return preventDefault(evt)
			}
		}
		
		enable && listen(['keydown'], handler)
	}(window.nobsgb = {}))
```

## 代码时间.cljs
core.cljs
```
(ns nobsgb.core
  (:require [nobsgb.dom :as dom]
            [nobsgb.pred :as pred]))

(def started false)
(defn ^:export start []
  (set! started true))
(defn ^:export stop []
  (set! started false))

(defn handler
  "keydown,keypress事件响应函数"
  [e]
  (when started
    (let [evt (dom/get-evt e)
          el (dom/get-el evt)
          key-code (dom/get-key-code evt)
          ctrl-key (dom/get-ctrl-key evt)
          read-only (dom/get-read-only el)
          type (dom/get-type el)
          content-editable (dom/get-content-editable el)
          tag (dom/get-tag el)]
      (if-not
        (pred/escapable?
          key-code read-only type tag content-editable ctrl-key)
        (dom/prevent-default evt)
        true))))

(defonce init
  (#(do
      (dom/listen! js/document "keydown" handler)
      #_(dom/listen! js/document "keypress" handler))))
```
dom.cljs
```
(ns nobsgb.dom)

(defn get-evt
  [e]
  (if (some? e) e (.event js/window)))

(defn get-el
  [e]
  (let [el (.-target e)]
    (if (some? el) el (.-srcElement e))))

(defn get-key-code
  [e]
  (.-keyCode e))

(defn get-ctrl-key
  [e]
  (.-ctrlKey e))

(defn get-read-only
  [el]
  (-> el (aget "readOnly") js/Boolean))

(defn get-type
  [el]
  (let [type (.-type el)]
    (if (some? tpye) type "")))

(defn get-tag
  [el]
  (.-tagName el))

(defn get-content-editable
  [el]
  (.-isContentEditable el))

(defn prevent-default
  [e]
  (if (some? (.-preventDefault e))
    (do
      (.preventDefault e)
      (set! (.-returnValue e) false)
      false)
    true))

(defn listen!
  [el evt-name handler]
  (cond
    (fn? (.-addEventListener el)) (.addEventListener el evt-name handler)
    (fn? (.-attachEvent el))      (.attachEvent el (str "on" evt-name) handler)
    :else (aset el (str "on" evt-name) handler)))

```
pred.cljs
```
(ns nobsgb.pred)
;;;; 断言

(defonce ^:const KEYCODES
  {:backspace 8
   :r 82})

(defn matches-key?
  "是否匹配指定键码"
  [indicated-key-code key-code]
  (= indicated-key-code key-code))

(def ^{:doc "是否为退格键"}
  backspace?
  (partial matches-key? (:backspace KEYCODES)))

(def ^{:doc "是否为字母R键"}
  r?
  (partial matches-key? (:r KEYCODES)))

(defn with-ctrl?
  "是否在按ctrl的基础上按其他键"
  [ctrl-key]
  (or (= ctrl-key "1")
      (true? ctrl-key)))

(defn ctrl+r?
  "是否为ctrl+r"
  [ctrl-key key-code]
  (and (with-ctrl? ctrl-key)
       (r? key-code)))
(def not-ctrl+r? (complement ctrl+r?))

(defn escapable-type?
  "是否为可跳过的type属性"
  [type]
  (some?
    (some->> type
      (re-matches #"(?i)text|password|tel|number|email|search|url"))))

(defn escapable-tag?
  "是否为可跳过的tag"
  [tag]
  (some?
    (some->> tag
      (re-matches #"(?i)input|textarea"))))

(def ^{:doc "是否设置为可编辑元素"}
  content-editable? identity)

(def ^{:doc "是否设置为只读"}
  read-only? identity)
(def writable? (complement read-only?))

(defn escapable-backspace?
  [key-code read-only type tag content-editable]
  (and (backspace? key-code)
       (writable? read-only)
       (or (escapable-type? type)
           (escapable-tag? tag)
           (content-editable? content-editable))))

(defn escapable?
  [key-code read-only type tag content-editable ctrl-key]
  (or
    (and (not-ctrl+r? ctrl-key key-code)
         (not (backspace? key-code)))
    (escapable-backspace? key-code read-only type tag content-editable)))
```
## 总结
&emsp;尊重原创，转载请注明来自：肥仔John^_^
