# WebComponent魔法堂:深究Custom Element 之 面向痛点编程

## 前言
&emsp;最近加入到新项目组负责前端技术预研和选型，一直偏向于以Polymer为代表的WebComponent技术线，于是查阅各类资料想说服老大向这方面靠，最后得到的结果是:"资料99%是英语无所谓，最重要是UI/UX上符合要求，技术的事你说了算。"，于是我只好乖乖地去学UI/UX设计的事，木有设计师撑腰的前端是苦逼的:(嘈吐一地后，还是挤点时间总结一下WebComponent的内容吧，为以后作培训材料作点准备。

## 浮在水面上的痛
### 组件噪音太多了！
&emsp;在使用Bootstrap的Modal组件时，我们不免要`Ctrl+c`然后`Ctrl+v`下面一堆代码
```
<div class="modal fade" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">Modal title</h4>
      </div>
      <div class="modal-body">
        <p>One fine body&hellip;</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->
```
![](./modal.png)
&emsp;一个不留神误删了一个结束标签，或拼错了某个class或属性那就悲催了，此时一个语法高亮、提供语法检查的编辑器是如此重要啊！但是我其实只想配置个Modal而已。
&emsp;由于元素信息由`标签标识符`,`元素特性`和`树层级结构`组成，所以排除噪音后提取的核心配置信息应该如下(YAML语法描述):
```
dialog:
  modal: true
  children:  
    header: 
      title: Modal title
      closable: true
    body:
      children:
        p:
          textContent: One fine body&hellip;
    footer
      children:
        button: 
          type: close
          textContent: Close
        button: 
          type: submit 
          textContent: Save changes
```
转换成HTML就是
```
<dialog modal>
  <dialog-header title="Modal title" closable></dialog-header>
  <dialog-body>
    <p>One fine body&hellip;</p>
  </dialog-body>
  <dialog-footer>
    <dialog-btn type="close">Close</dialog-btn>
    <dialog-btn type="submit">Save changes</dialog-btn>
  </dialog-footer>
</dialog>
```
而像Alert甚至可以极致到这样
```
<alert>是不是很简单啊？</alert>
```
可惜浏览器木有提供`<alert></alert>`，那怎么办呢？
### 手打牛丸模式1
既然浏览器木有提供，那我们自己手写一个吧！
```
<script>
'use strict'
class Alert{
  constructor(el = document.createElement('ALERT')){
    this.el = el
    const raw = el.innerHTML
    el.dataset.resolved = ''
    el.innerHTML = `<div class="alert alert-warning alert-dismissible fade in">
                      <button type="button" class="close" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                      </button>
                      ${raw}
                    </div>`
    el.querySelector('button.close').addEventListener('click', _ => this.close())
  }
  close(){
    this.el.style.display = 'none'
  }
  show(){
    this.el.style.display = 'block'
  }
}

function registerElement(tagName, ctorFactory){
  [...document.querySelectorAll(`${tagName}:not([data-resolved])`)].forEach(ctorFactory)
}
function registerElements(ctorFactories){
  for(let k in ctorFactories){
    registerElement(k, ctorFactories[k])
  }
}
```
清爽一下！
```
<alert>舒爽多了！</alert>
<script>
registerElements({alert: el => new Alert(el)})
</script>
```
### 复盘找问题
&emsp;虽然表面上实现了需求，但存在2个明显的缺陷
1. 不完整的元素实例化方式
原生元素有2种实例化方式
a. 声明式
```
<!-- 由浏览器自动完成 元素实例化 和 添加到DOM树 两个步骤 -->
<input type="text">
```
b. 命令式
```
// 元素实例化
const input = new HTMLInputElement() // 或者 document.createElement('INPUT')
input.type = 'text'
// 添加到DOM树
document.querySelector('#mount-node').appendChild(input)
```
&emsp;由于声明式注重What to do，而命令式注重How to do，并且我们操作的是DOM，所以采用声明式的HTML标签比命令式的JavaScript会来得简洁平滑。但当我们需要动态实例化元素时，命令式则是最佳的选择。于是我们勉强可以这样
```
// 元素实例化
const myAlert = new Alert()
// 添加到DOM树
document.querySelector('#mount-node').appendChild(myAlert.el)
/*
由于Alert无法正常实现HTMLElement和Node接口，因此无法实现
document.querySelector('#mount-node').appendChild(myAlert)
myAlert和myAlert.el的差别在于前者的myAlert是元素本身，而后者则是元素句柄，其实没有明确哪种更好，只是原生方法都是支持操作元素本身，一下来个不一致的句柄不蒙才怪了
*/
```
&emsp;即使你能忍受上述的代码，那通过`innerHTML`实现半声明式的动态元素实例化，那又怎么玩呢？是再手动调用一下`registerElement('alert', el => new Alert(el))`吗？
&emsp;更别想通过`document.createElement`来创建自定义元素了。
2. 有生命无周期
&emsp;元素的生命从实例化那刻开始，然后经历如添加到DOM树、从DOM树移除等阶段，而想要更全面有效地管理元素的话，那么捕获各阶段并完成相应的处理则是唯一有效的途径了。

## 生命周期很重要
&emsp;当定义一个新元素时，有3件事件是必须考虑的：
1. 元素自闭合: 元素自身信息的自包含，并且不受外部上下文环境的影响;
2. 元素的生命周期: 通过监控元素的生命周期，从而实现不同阶段完成不同任务的目录;  
3. 元素间的数据交换: 采用property in, event out的方式与外部上下文环境通信，从而与其他元素进行通信。
&emsp;元素自闭合貌似无望了，下面我们试试监听元素的生命周期吧！

### 手打牛丸模式2
&emsp;通过`constructor`我们能监听元素的创建阶段，但后续的各个阶段呢？可幸的是可以通过`MutationObserver`监听`document.body`来实现:)
最终得到的如下版本:
```
'use strict'
class Alert{
  constructor(el = document.createElement('ALERT')){
    this.el = el
    this.el.fireConnected = () => { this.connectedCallback && this.connectedCallback() }
    this.el.fireDisconnected = () => { this.disconnectedCallback && this.disconnectedCallback() }
    this.el.fireAttributeChanged = (attrName, oldVal, newVal) => { this.attributeChangedCallback && this.attributeChangedCallback(attrName, oldVal, newVal) } 

    const raw = el.innerHTML
    el.dataset.resolved = ''
    el.innerHTML = `<div class="alert alert-warning alert-dismissible fade in">
                      <button type="button" class="close" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                      </button>
                      ${raw}
                    </div>`
    el.querySelector('button.close').addEventListener('click', _ => this.close())
  }
  close(){
    this.el.style.display = 'none'
  }
  show(){
    this.el.style.display = 'block'
  }
  connectedCallback(){
    console.log('connectedCallback')
  }
  disconnectedCallback(){
    console.log('disconnectedCallback')
  }
  attributeChangedCallback(attrName, oldVal, newVal){
    console.log('attributeChangedCallback')
  }
}

function registerElement(tagName, ctorFactory){
  [...document.querySelectorAll(`${tagName}:not([data-resolved])`)].forEach(ctorFactory)
}
function registerElements(ctorFactories){
  for(let k in ctorFactories){
    registerElement(k, ctorFactories[k])
  }
}

const observer = new MutationObserver(records => {
  records.forEach(record => {
    if (record.addedNodes.length && record.target.hasAttribute('data-resolved')){
      // connected
      record.target.fireConnected()
    }
    else if (record.removedNodes.length){
      // disconnected
      const node = [...record.removedNodes].find(node => node.hasAttribute('data-resolved'))
      node && node.fireDisconnected()
    }
    else if ('attributes' === record.type && record.target.hasAttribute('data-resolved')){
      // attribute changed
      record.target.fireAttributeChanged(record.attributeName, record.oldValue, record.target.getAttribute(record.attributeName))
    }
  })
})
observer.observe(document.body, {attributes: true, childList: true, subtree: true})

registerElement('alert', el => new Alert(el))
```

## 总结
&emsp;千辛万苦撸了个基本不可用的自定义元素模式，但通过代码我们进一步了解到对于自定义元素我们需要以下基本特性:
1. 自定义元素可通过原有的方式实例化(`<custom-element></custom-element>`,`new CustomElement()`和`document.createElement('CUSTOM-ELEMENT')`) 
2. 可通过原有的方法操作自定义元素实例(如`document.body.appendChild`等)
3. 能监听元素的生命周期
下一篇《WebComponent魔法堂:深究Custom Element 之 标准构建》中，我们将一同探究H5标准中Custom Element API，并利用它来实现满足上述特性的自定义元素:)
&emsp;尊重原创，转载请注明来自: ^_^肥仔John

## 感谢
[Custom ELement](http://www.html5rocks.com/en/tutorials/webcomponents/customelements/)
[Custom ELement v1](https://developers.google.com/web/fundamentals/primers/customelements)
[MutationObserver](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver)
