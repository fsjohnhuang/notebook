# WebComponent魔法堂:深究Custom Element 之 标准构建

## 前言
&emsp;通过《WebComponent魔法堂:深究Custom Element 之 面向痛点编程》，我们明白到其实Custom Element并不是什么新东西，我们甚至可以在IE5.5上定义自己的`alert`元素。但这种简单粗暴的自定义元素并不是我们需要的，我们需要的是具有以下特点的自定义元素：
1. 自定义元素可通过原有的方式实例化(`<custom-element></custom-element>`,`new CustomElement()`和`document.createElement('CUSTOM-ELEMENT')`) 
2. 可通过原有的方法操作自定义元素实例(如`document.body.appendChild`,可被CSS样式所修饰等)
3. 能监听元素的生命周期
&emsp;而Google为首提出的H5 Custom Element让我们可以在原有标准元素的基础上向浏览器注入各种抽象层次更高的自定义元素，并且在元素CRUD操作上与原生API无缝对接，编程体验更平滑。下面我们一起来通过H5 Custom Element来重新定义`alert`元素吧！

## 命名这件“小事”
&emsp;在正式撸代码前我想让各位最头痛的事应该就是如何命名元素了,下面3个因素将影响我们的命名：
1. 命名冲突。自定义组件如同各种第三方类库一样存在命名冲突的问题，那么很自然地会想到引入命名空间来解决，但由于组件的名称并不涉及组件资源加载的问题，因此我们这里简化一下——为元素命名添加前缀即可，譬如采用很JAVA的`com-cnblogs-fsjohnhuang-alert`。
2. 语义化。语义化我们理解就是元素名称达到望文生义的境界，譬如`x-alert`一看上去就是知道`x`是前缀而已跟元素的功能无关，`alert`才是元素的功能。
3. 足够的吊:)高大上的名称总让人赏心悦目，就像我们项目组之前开玩笑说要把预警系统改名为"超级无敌全球定位来料品质不间断跟踪预警综合平台"，呵呵！
&emsp;除了上述3点外，H5规范中还有这条规定：自定义元素必须至少包含一个连字符，即最简形式也要这样`a-b`。而不带连字符的名称均留作浏览器原生元素使用。换个说法就是**名称带连字符的元素被识别为有效的自定义元素，而不带连字符的元素要么被识别为原生元素，要么被识别为无效元素。**
```
const compose = (...fns) => {
  const lastFn = fns.pop()
  fns = fns.reverse()
  return a => fns.reduce((p, fn) => fn(p), lastFn(a))
}
const info = msg => console.log(msg)
const type = o => Object.prototype.toString.call(o)
const printType = compose(info, type)

const newElem = tag => document.createElement(tag)

// 创建有效的自定义元素
const xAlert = newElem('x-alert')
infoType(xAlert) // [object HTMLElement]

// 创建无效的自定义元素
const alert = newElem('alert')
infoType(alert) // [object HTMLUnknownElement]

// 创建有效的原生元素
const div = newElem('div')
infoType(div) // [object HTMLDivElement]
```
&emsp;那如果我偏要用`alert`来自定义元素呢？浏览器自当会说一句“悟空，你又调皮了”
![](alert_error.png)

&emsp;现在我们已经通过命名规范来有效区分自定义元素和原生元素，并且通过前缀解决了命名冲突问题。嘿稍等，添加前缀真的是解决命名冲突的好方法吗？这其实跟通过添加前缀解决id冲突一样，假如有两个元素发生命名冲突时，我们就再把前缀加长直至不再冲突为止，那就有可能出现很JAVA的`com-cnblogs-fsjohnhuang-alert`的命名，噪音明显有点多，直接降低语义化的程度，重点还有每次引用该元素时都要敲这么多字符，打字的累看的也累。这一切的根源就是有且仅有一个Scope——Global Scope，因此像解决命名冲突的附加信息则无法通过上下文来隐式的提供，直接导致需要通过前缀的方式来硬加上去。
&emsp;前缀的方式我算是认了，但能不能少打写字呢？像命名空间那样
木有命名冲突时
```python
#!usr/bin/env python
# -*- coding: utf-8 -*-
from django.http import HttpResponse

def index(request):
  return HttpResponse('Hello World!')
``` 
存在命名冲突时
```python
#!usr/bin/env python
# -*- coding: utf-8 -*-
import django.db.models
import peewee

type(django.db.models.CharField)
type(peewee.CharField)
``` 
前缀也能有选择的省略就好了！

## 把玩Custome Element v0 
&emsp;对元素命名吐嘈一地后，是时候把玩API了。
### 从头到脚定义新元素
```
/** x-alert元素定义 **/
const xAlertProto = Object.create(HTMLElement.prototype, {
  /* 元素生命周期的事件 */
  // 实例化时触发
  createdCallback: {
    value: function(){
      console.log('invoked createCallback!')

      const raw = this.innerHTML
      this.innerHTML = `<div class="alert alert-warning alert-dismissible fade in">
                          <button type="button" class="close" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                          </button>
                          <div class="content">${raw}</div>
                        </div>`
      this.querySelector('button.close').addEventListener('click', _ => this.close())
    }
  },
  // 元素添加到DOM树时触发
  attachedCallback: {
    value: function(){
      console.log('invoked attachedCallback!')
    }
  },
  // 元素DOM树上移除时触发
  detachedCallback: {
    value: function(){
      console.log('invoked detachedCallback!')
    }
  },
  // 元素的attribute发生变化时触发
  attributeChangedCallback: {
    value: function(attrName, oldVal, newVal){
      console.log(`attributeChangedCallback-change ${attrName} from ${oldVal} to ${newVal}`)
    }
  },
  /* 定义元素的公有方法和属性 */
  // 重写textContent属性
  textContent: {
    get: function(){ return this.querySelector('.content').textContent },
    set: function(val){ this.querySelector('.content').textContent = val }
  },
  close: {
    value: function(){ this.style.display = 'none' }
  },
  show: {
    value: function(){ this.style.display = 'block' }
  }
}) 
// 向浏览器注册自定义元素
const XAlert = document.registerElement('x-alert', { prototype: xAlertProto })

/** 操作 **/
// 实例化
const xAlert1 = new XAlert() // invoked createCallback!
const xAlert2 = document.createElement('x-alert') // invoked createCallback!
// 添加到DOM树
document.body.appendChild(xAlert1) // invoked attachedCallback!
// 从DOM树中移除
xAlert1.remove() // invoked detachedCallback!
// 仅作为DIV的子元素，而不是DOM树成员不会触发attachedCallback和detachedCallback函数
const d = document.createElement('div')
d.appendChild(xAlert1)
xAlert1.remove()
// 访问元素实例方法和属性
xAlert1.textContent = 1
console.log(xAlert1.textContent) // 1
xAlert1.close()
// 修改元素实例特性
xAlert1.setAttribute('d', 1) // attributeChangedCallback-change d from null to 1
xAlert1.removeAttribute('d') // attributeChangedCallback-change d from 1 to null 
// setAttributeNode和removeAttributeNode方法也会触发attributeChangedCallback
```
&emsp;上面通过定义`x-alert`元素展现了Custom Element的所有API，其实就是继承`HTMLElement`接口，然后选择性地实现4个生命周期回调方法，而在`createdCallback`中书写自定义元素内容展开的逻辑。另外可以定义元素公开属性和方法。最后通过`document.registerElement`方法告知浏览器我们定义了全新的元素，你要好好对它哦！
&emsp;那现在的问题在于假如`<x-alert></x-alert>`这个HTML Markup出现在`document.registerElement`调用之前，那会出现什么情况呢？这时的`x-alert`元素处于unresolved状态，并且可以通过CSS Selector `:unresolved`来捕获，当执行`document.registerElement`后，`x-alert`元素则处于resolved状态。于是可针对两种状态作样式调整，告知用户处于unresolved状态的元素暂不可用，敬请期待。 
```
<style>
  x-alert{
    display: block;
  }
  x-alert:unresolved{
    content: 'LOADING...';
  }
</style>
```

### 渐进增强原生元素
&emsp;有时候我们只是想在现有元素的基础上作些功能增强，倘若又要从头做起那也太折腾了，幸好Custom Element规范早已为我们想好了。下面我们来对input元素作增强
```
const xInputProto = Object.create(HTMLInputElement.prototype, {
  createdCallback: {
    value: function(){ this.value = 'x-input' }
  },
  isEmail: {
    value: function(){
      const val = this.value
      return /[0-9a-zA-Z]+@\S+\.\S+/.test(val)
    }
  }
})
document.registerElement('x-input', {
  prototype: xInputProto,
  extends: 'input'
})

// 操作
const xInput1 = document.createElement('input', 'x-input') // <input is="x-input">
console.log(xInput1.value) // x-input
console.log(xInput1.isEmail()) // false
```

## Custom Element v1 —— 换个装而已啦
&emsp;Custom Element API现在已经升级到v1版本了，其实就是提供一个专门的`window.customElements`作为入口来统一管理和操作自定义元素，并且以对ES6 class更友善的方式定义元素，其中的步骤和概念并没有什么变化。下面我们采用Custom Element v1的API重写上面两个示例
1. 从头定义
```
class XAlert extends HTMLElement{
  // 相当于v0中的createdCallback，但要注意的是v0中的createdCallback仅元素处于resolved状态时才触发，而v1中的constructor就是即使元素处于undefined状态也会触发，因此尽量将操作延迟到connectedCallback里执行
  constructor(){
    super() // 必须调用父类的构造函数

    const raw = this.innerHTML
    this.innerHTML = `<div class="alert alert-warning alert-dismissible fade in">
                        <button type="button" class="close" aria-label="Close">
                          <span aria-hidden="true">&times;</span>
                        </button>
                        <div class="content">${raw}</div>
                      </div>`
    this.querySelector('button.close').addEventListener('click', _ => this.close())
  }
  // 相当于v0中的attachedCallback
  connectedCallback(){
    console.log('invoked connectedCallback!')
  }
  // 相当于v0中的detachedCallback
  disconnectedCallback(){
    console.log('invoked disconnectedCallback!')
  }
  // 相当于v0中的attributeChangedCallback,但新增一个可选的observedAttributes属性来约束所监听的属性数目
  attributeChangedCallback(attrName, oldVal, newVal){
    console.log(`attributeChangedCallback-change ${attrName} from ${oldVal} to ${newVal}`)
  }
  // 缺省时表示attributeChangedCallback将监听所有属性变化，若返回数组则仅监听数组中的属性变化
  static get observedAttributes(){ return ['disabled'] }
  // 新增事件回调，就是通过document.adoptNode方法修改元素ownerDocument属性时触发
  adoptedCallback(){
    console.log('invoked adoptedCallback!')
  }
  get textContent(){
    return this.querySelector('.content').textContent
  }
  set textContent(val){
    this.querySelector('.content').textContent = val
  }
  close(){
    this.style.display = 'none'
  }
  show(){
    this.style.display = 'block'
  }
}
customElements.define('x-alert', XAlert)
```
2. 渐进增强 
```
class XInput extends HTMLInputElement{
  constructor(){
    super()

    this.value = 'x-input'
  }
  isEmail(){
    const val = this.value
    return /[0-9a-zA-Z]+@\S+\.\S+/.test(val)
  }
}
customElements.define('x-input', XInput, {extends: 'input'})

// 实例化方式
document.createElement('input', {is: 'x-input'})
new XInput()
<input is="x-input">
```
&emsp;除此之外之前的unresolved状态改成defined和undefined状态，CSS对应的选择器为`:defined`和`:not(:defined)`。
&emsp;还有就是新增一个`customeElements.whenDefined({String} tagName):Promise`方法，让我们能监听自定义元素从undefined转换为defined的事件。
```
<share-buttons>
  <social-button type="twitter"><a href="...">Twitter</a></social-button>
  <social-button type="fb"><a href="...">Facebook</a></social-button>
  <social-button type="plus"><a href="...">G+</a></social-button>
</share-buttons>

// Fetch all the children of <share-buttons> that are not defined yet.
let undefinedButtons = buttons.querySelectorAll(':not(:defined)');

let promises = [...undefinedButtons].map(socialButton => {
  return customElements.whenDefined(socialButton.localName);
));

// Wait for all the social-buttons to be upgraded.
Promise.all(promises).then(() => {
  // All social-button children are ready.
});
```

## 从头定义一个刚好可用的元素不容易啊！
&emsp;到这里我想大家已经对Custom Element API有所认识了，下面我们尝试自定义一个完整的元素吧。不过再实操前，我们先看看一个刚好可用的元素应该注意哪些细节。
### 明确各阶段适合的操作
1. constructor
&emsp;用于初始化元素的状态和设置事件监听，或者创建Shadow Dom。
2. connectedCallback
&emsp;资源获取和元素渲染等操作适合在这里执行，但该方法可被调用多次，因此对于只执行一次的操作要自带检测方案。
3. disconnectedCallback
&emsp;适合作资源清理等工作(如移除事件监听)
### 更细的细节
1. constructor中的细节
1.1. 第一句必须调用`super()`保证父类实例创建
1.2. `return`语句要么没有，要么就只能是`return`或`return this`
1.3. 不能调用`document.write`和`document.open`方法
1.4. 不要访问元素的特性(attribute)和子元素，因为元素可能处于undefined状态并没有特性和子元素可访问
1.5. 不要设置元素的特性和子元素，因为即使元素处于defined状态，通过`document.createElement`和`new`方式创建元素实例时，本应该是没有特性和子元素的
2. 打造focusable元素 by tabindex特性
&emsp;默认情况下自定义元素是无法获取焦点的，因此需要显式添加`tabindex`特性来让其focusable。另外还要注意的是若元素`disabled`为`true`时，必须移除`tabindex`让元素unfocusable。
3. ARIA特性
&emsp;通过ARIA特性让其他阅读器等其他访问工具可以识别我们的自定义元素。
4. 事件类型转换
&emsp;通过`addEventListener`捕获事件，然后通过`dispathEvent`发起事件来对事件类型进行转换，从而触发更符合元素特征的事件类型。

下面我们来撸个`x-btn`吧
```
class XBtn extends HTMLElement{
  static get observedAttributes(){ return ['disabled'] }
  constructor(){
    super()

    this.addEventListener('keydown', e => {
      if (!~[13, 32].indexOf(e.keyCode)) return  

      this.dispatchEvent(new MouseEvent('click', {
        cancelable: true,
        bubbles: true
      }))
    })

    this.addEventListener('click', e => {
      if (this.disabled){
        e.stopPropagation()
        e.preventDefault()
      }
    })
  }
  connectedCallback(){
    this.setAttribute('tabindex', 0)
    this.setAttribute('role', 'button')
  }
  get disabled(){
    return this.hasAttribute('disabled')
  }
  set disabled(val){
    if (val){
      this.setAttribute('disabled','')
    }
    else{
      this.removeAttribute('disabled')
    }
  }
  attributeChangedCallback(attrName, oldVal, newVal){
    this.setAttribute('aria-disabled', !!this.disabled)
    if (this.disabled){
      this.removeAttribute('tabindex')
    }
    else{
      this.setAttribute('tabindex', '0')
    }
  }
}
customElements.define('x-btn', XBtn)
```

## 如何开始使用Custom Element v1?
&emsp;Chrome54默认支持Custom Element v1，Chrome53则须要修改启动参数`chrome --enable-blink-features=CustomElementsV1`。其他浏览器可使用webcomponets.js这个polyfill。


## 题外话一番
&emsp;关于Custom Element我们就说到这里吧，不过我在此提一个有点怪但又确实应该被注意到的细节问题，那就是自定义元素是不是一定要采用`<x-alert></x-alert>`来声明呢？能否采用`<x-alert/>`或`<x-alert>`的方式呢？
&emsp;答案是不行的，由于自定义元素属于Normal Element，因此必须采用`<x-alert></x-alert>`这种开始标签和闭合标签来声明。那么什么是Normal Element呢？
其实元素分为以下5类：
1. Void elements
&emsp;格式为`<tag-name>`,包含以下元素`area`,`base`,`br`,`col`,`embed`,`hr`,`img`,`keygen`,`link`,`meta`,`param`,`source`,`track`,`wbr`
2. Raw text elements
&emsp;格式为`<tag-name></tag-name>`,包含以下元素`script`,`style`
3. escapable raw text elements
&emsp;格式为`<tag-name></tag-name>`,包含以下元素`textarea`,`title`
4. Foreign elements
&emsp;格式为`<tag-name/>`,MathML和SVG命名空间下的元素
5. Normal elements
&emsp;格式为`<tag-name></tag-name>`,除上述4种元素外的其他元素。某些条件下可以省略结束标签，因为浏览器会自动为我们补全，但结果往往会很吊轨，所以还是自己写完整比较安全。


## 总结
&emsp;当头一回听到Custom Element时我是那么的兴奋不已，犹如找到根救命稻草似的。但如同其他新技术的出现一样，利弊同行，如何判断和择优利用是让人头痛的事情，也许前人的经验能给我指明方向吧！下篇《WebComponent魔法堂:深究Custom Element 之 从过去看现在》，我们将穿越回18年前看看先驱HTML Component的黑历史，然后再次审视WebComponent吧！
&emsp;尊重原创，转载请注明来自：^_^肥仔John

## 感谢
[How to Create Custom HTML Elements](http://blog.teamtreehouse.com/create-custom-html-elements-2)
[A vocabulary and associated APIs for HTML and XHTML](https://www.w3.org/TR/html5/syntax.html)
[Custom Elements v1](https://developers.google.com/web/fundamentals/getting-started/primers/customelements#progressively_enhanced_html)
[custom-elements-customized-builtin-example](https://html.spec.whatwg.org/multipage/scripting.html#custom-elements-customized-builtin-example)
