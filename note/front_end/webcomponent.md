Issues of HTML
1. ID confliction by global namespace
2. No bindings, no expressions and no flow controls
3. No wrapping solutions

Issues of CSS
1. selectors confliction by global namespace
2. no bindings, no expressions and no flow controls
3. cascade change the priorities of style rules, make it hard to predicate the consult.
4. 无法复用



Element.createShadowRoot()

Element.attachShadow(shadowRootInit:Object):ShadowRoot
creates and attaches a shadow DOM tree to the specified element.
shadowRootInit(encapsulation mode)
possible values: open,
                 closed
```
el.attachShadow({mode: 'open'})
```

Element.getDestinationInsertionPoints()
get what insertion points the specified node is distributed into

Element.getDistributedNodes()

Insertion points
`<content select="css selectors">` (HTMLContentElement)-> `<slot>`
```
document.createElement('content')
```

Element.shadowRoot
属性
host,指向shadowHost 

Element.assignedSlot
TextNode.assignedSlot
Event.composedPath(), events associated with elements inside the shadow DOM.

HTMLSlotElement.assignedNodes(opts)
获取对应的distributed nodes, opts = {flatten: true}，表示返回值中包含slot的fallback content.


Shadow DOM v0
多个
Shadow insertion points
`<shadow>` (HTMLShadowElement)
```
document.createElement('shadow')
```

shadow dom
shadow host
shadow tree
shadow root
light dom
distributed nodes

blocked events
```
abort
error
select
change
load
reset
resize
scroll
selectstart
```

event重定向
event.path，事件冒泡经过的元素数组，第一个元素是srcElement。



`:host`, selects a shadow host element.
```
:host(.fancy){
  display: inline-block;
}
```
`:host-context`, selects a shadow host element based on a matching parent element.
```
:host-context(.blocky){
  display: block;
}
```
`::content` -> `::slotted`, selects distributed nodes inside of an element.
```
::content h1{
  color: red;
}

/* slotted just can select top-level children. */
::slotted(h1){
  color: red;
}
```

Shadow DOM组成和结构
Light/Normal DOM，就是Shadow DOM面世前我们一直在用的DOM。
Shadow Host, Shadow DOM的宿主元素.(v0中Shadow Host是`<shadow>`或属于Light DOM的元素，而v1中Shadow Host一定属于Light DOM)
Shadow Root, Shadow DOM Tree的document节点
Distributed Nodes,位于Shadow Host下的Light DOM

封装
Style Isolation
CSS, scoped style, 后期会实现scoped stylesheets
HTML，隔离
JS，依靠JS自身的Module实现

与外界通讯
HTML API
JS API
CSS API

inherited css rule，可从Light DOM传递到Shadow DOM。通过`all:initial`重置所有样式会浏览器默认样式
```
all: 表示重设除unicode-bidi和direction之外的所有CSS属性的属性值
initial, 表示采用CSS规范定义的属性初始值
revert, 采用样式表或浏览器定义的样式表
inherit, 表示继承父元素的样式属性的计算值,即使该样式是非可继承样式也会被继承下来
unset, 默认值, 表示若该属性为可继承的，则采用inherit；否则则采用initial。
```
[The inherit, initial, and unset values](http://www.quirksmode.org/css/cascading/values.html)



## Ref
[神秘的 shadow-dom 浅析](http://www.cnblogs.com/coco1s/p/5711795.html)
[HTML Imports #include for the web](http://www.html5rocks.com/en/tutorials/webcomponents/imports/)
[Custom Elements defining new elements in HTML](http://www.html5rocks.com/en/tutorials/webcomponents/customelements/)
[Shadow DOM 101](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom/)
[Shadow DOM 201](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom-201/)
[<content>](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/content)
[Introducing Slot-Based Shadow DOM API](https://webkit.org/blog/4096/introducing-shadow-dom-api/)
[Proposal for changes to manage Shadow DOM content distribution](https://lists.w3.org/Archives/Public/public-webapps/2015AprJun/0184.html)
[Imperative API for Insertion Points](https://lists.w3.org/Archives/Public/public-webapps/2014JanMar/0376.html)
[Proposal-for-changes-to-manage-Shadow-DOM-content-distribution](https://github.com/w3c/webcomponents/blob/gh-pages/proposals/Proposal-for-changes-to-manage-Shadow-DOM-content-distribution.md)
[+WebcomponentsOrg](https://plus.google.com/+WebcomponentsOrg)
[Shadow DOM 301 Advanced Concepts & DOM APIs](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom-301/)
[CSS-Scoping](https://drafts.csswg.org/css-scoping/)
[CSS-Variables](http://dev.w3.org/csswg/css-variables/)
[MutationObserver](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver)
[Shadow DOM CSS Cheat Sheet](http://robdodson.me/shadow-dom-css-cheat-sheet/)
