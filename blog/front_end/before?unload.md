# JS魔法堂:定义页面的Dispose方法——[before]unload事件启示录
## 前言
&emsp;最近实施的同事报障，说用户审批流程后直接关闭浏览器，操作十余次后系统就报用户会话数超过上限，咨询4A同事后得知登陆后需要显式调用登出API才能清理4A端，否则必然会超出会话上限。
&emsp;即使在页面上增添一个登出按钮也无法保证用户不会直接关掉浏览器，更何况用户已经习惯这样做，增加功能好弄，改变习惯却难啊。这时想起N年用过的`window.onbeforeunload`和`window.onunload`事件。
&emsp;本文记录重拾这两个家伙的经过，以便日后用时少坑。

## 为网页写个Dispose方法
&emsp;C#中我们会将释放非托管资源等收尾工作放到Dispose方法中, 然后通过`using`语句块自动调用该方法。对于网页何尝不是有大量收尾工作需要处理呢？那我们是否也有类似的机制，让程序变得更健壮呢？——那就靠`beforeunload`和`unload`事件了。但相对C#通过`using`语句块自动调用Dispose方法，`beforeunload`和`unload`的触发点则复杂不少。
&emsp;我们看看什么时候会触发这两个事件呢？
1. 在浏览器地址栏输入地址，然后点击跳转；
2. 点击页面的链接实现跳转；
3. 关闭或刷新当前页面;
4. 操作当前页面的`Location`对象,修改当前页面地址;
5. 调用`window.navigate`实现跳转;
6. 调用`window.open`或`document.open`方法在当前页面加载其他页面或重新打开输入流。
&emsp;OMG!这么多操作会触发这两兄弟，怎么处理才好啊？没啥办法，针对功能需求做取舍咯。对于我的需求就是在页面的Dispose方法中调用登出API，经过和实施同事的沟通——只要刷新页面就触发登出。
```
;(function(exports, $, url){
  exports.dispose = $.proxy($.get, $, url)
}(window, $, "http://pseudo.com/logout"))
```
那现在剩下的问题就在于到底是在`beforeunload`还是`unload`事件处理函数中调用dispose方法呢？这里涉及两点需要探讨:
1. `beforeunload`和`unload`的功能定位是什么？
2. `beforeunload`和`unload`的兼容性.

### `beforeunload`和`unload`的功能定位是什么？
&emsp;`beforeunload`顾名思义就是在`unload`前触发，可通过弹出二次确认对话框来试图终断执行unload.
&emsp;`unload`就是正在进行页面内容卸载时触发的，一般在这里进行一些重要的清理善后工作，而这时页面处于以下一个特殊的临时状态:
1. 页面所有资源(img, iframe等)均未被释放;
2. 页面可视区域一片空白;
3. UI人机交互失效(`window.open,alert,confirm`全部失效);
4. 没有任何操作可以阻止`unload`过程的执行。(`unload`事件的Cancelable属性值为No)
&emsp;那么反过来看看`beforeunload`事件，这时页面状态大致与平常一致：
1. 页面所有资源均未释放，且页面可视区域效果没有变化;
2. UI人机交互失效(`window.open,alert,confirm`全部失效);
3. 最后时机可以阻止`unload`过程的执行.(`beforeunload`事件的Cancelable属性值为Yes)

### `beforeunload`和`unload`的兼容性
&emsp;对于移动端浏览器而言(Safari, Opera Mobile等)而言不支持`beforeunload`事件,也许是因为移动端不建议干扰用户操作流程吧。


## 防数据丢失机制——二次确认
&emsp;当用户正在编辑状态时，若因误操作离开页面而导致数据丢失常作为例外处理。处理方式大概有3种:
1. 丢了就丢呗,然后就是谁用谁受罪了;
2. 简单粗暴——侦测处于编辑状态时，监听`beforeunload`事件作二次确定,也就是将责任抛给用户;
3. 自动保存，甚至做到Work in Progress(参考john papa的分享[John Papa-Progressive Savingr-NG-Conf](https://www.youtube.com/watch?v=JLij19xbefI))
&emsp;这里我们选择方式2，弹出二次确定对话框。想到对话框自然会想到`window.confirm`，然后很自然地输入以下代码
```
window.addEventListener('beforeunload', function(e){
  var msg = "Do u want to leave?\nChanges u made may be lost."
  if (!window.confirm(msg)){
    e.preventDefault()
  }
})
```
然后刷新页面发现啥都没发生，接着直接蒙了。。。。。。
### 坑1: 无视`window.alert/confirm/prompt/showModalDialog`
&emsp;`beforeunload`和`unload`是十分特殊的事件，要求事件处理函数内部不能阻塞当前线程，而`window.alert/confirm/prompt/showModalDialog`却恰恰就会阻塞当前线程，因此H5规范中以明确在`beforeunload`和`unload`中直接无视这几个方法的调用。
>Since 25 May 2011, the HTML5 specification states that calls to `window.showModalDialog()`, `window.alert()`, `window.confirm()` and `window.prompt()` methods may be ignored during this event.(onbeforeunload#Notes)[https://developer.mozilla.org/en-US/docs/Web/API/WindowEventHandlers/onbeforeunload#Notes]

在chrome/chromium下会报"Blocked alert/prompt/confirm() during beforeunload/unload."的JS异常，而firefox下则连异常都懒得报。
&emsp;既然不给用`window.confirm`,那么如何弹出二次确定对话框呢？其实`beforeunload`事件已经为我们准备好了。只要改成
```
window.onbeforeunload = function(){
  var msg = "Do u want to leave?\nChanges u made may be lost."
  return msg
}
```
&emsp;通过DOM0 Event Model的方式监听beforeunload事件时，只需返回值不为undefined或null，即会弹出二次确定对话框。而IE和Chrome/Chromium则以返回值作为对话框的提示信息，Firefox4开始会忽略返回值仅显式内置的提示信息.
&emsp;太不上道了吧，还在用DOM0 Event Model:( 那我们来看看DOM2 Event Model是怎么一个玩法
```
// Microsoft DOM2-ish Event Model
window.attachEvent('onbeforeunload', function(){
  var msg = "Do u want to leave?\nChanges u made may be lost."
  var evt = window.event
  evt.returnValue = msg
})
```
对于巨硬独有的DOM2 Event Model，我们通过设置`window.event.returnValue`为非null或undefined来实现弹出窗的功能（注意：函数返回值是无效果的）
那么标准的DOM2 Event Model呢？我记得`window.event.returnValue`是 for ie only的，但事件处理函数的返回值又木有效果，那只能想到`event.preventDefault()`了,但`event.preventDefault()`没有带入参的重载，那么是否意味通过标准DOM2 Event Model的方式就不支持自定义提示信息呢？
```
window.addEventListeners('beforeunload', function(e){
  e.preventDefault()
})
```
在FireFox上成功弹出对话框，但Chrome/Chromium上却啥都没发生。。。。。。
### 坑2: `HTMLElement.addEventListener`事件绑定
&emsp;`event.preventDefault()`这一玩法就FireFox支持，Chrome这次站到IE的队列上了。综合起来的玩法是这样的
```
;(function(exports){
  exports.genDispose = genDispose

  /**
   * @param {Function|String} [fnBody] - executed within the dispose method when it's data type is Function
   *                                     as return value of dispose method when it's data type is String
   * @param {String} [returnMsg]       - as return value of dispose method
   * @returns {Function}               - dispose method
   */
  function genDispose(fnBody, returnMsg){
    var args = getArgs(arguments)

    return function(e){
      args.fnBody && args.fnBody()
      if(e = e || window.event){
        args.returnMsg && e.preventDefault && e.preventDefault()
        e.returnValue = args.returnMsg
      }

      return args.returnMsg    
    }
  }

  function getArgs(args){
    var ret = {fnBody: void 0, returnMsg: args[1]},
        typeofArg0 = typeof args[0]

    if ("string" === typeofArg0){
      ret.returnMsg = args[0]
    }
    else if ("function" === typeofArg0){
      ret.fnBody = args[0]
    }

    retrn ret
  }

}(window))

// uses
var dispose = genDispose("Do u want to leave?\nChanges u made may be lost.")
window.onbeforeunload = dispose
window.attachEvent('onbeforeunload', dispose)
window.addEventListener('beforeunload', dispose)
```
### 坑3: 尊重用户的选择
&emsp;有办法阻止用户关闭或刷新页面吗？没办法，二次确定已经是对用户操作的最大限度的干扰了。

## 问题未解决——Cross-domain Redirection
```
;(function(exports){
  exports.Logout = Logout

  function Logout(url){
    if (this instanceof Logout);else return new Logout(url)
    this.url = url
  }
  Logout.prototype.exec = function(){
    var xhr = new XMLHttpRequest()
    xhr.open("GET", this.url, false)
    xhr.send()
  }
}(window))

var url = "http://pseudo.com/logout",
    logout = new Logout(url)
var dispose = $.proxy(logout.exec, logout)

var prefix = 'on'
(window.attachEvent || (prefix='', window.addEventListener))(prefix + 'unload', dispose)
```
&emsp;当我以为这样就能交功课时，却发现登出url响应状态编码为302，而响应头Location指向另一个域的资源，并且不存在Access-Control-Allow-Origin等CORS响应头信息，而XHR对象不支持Cross-domain Redirection，因此登出失效。
&emsp;以前只知道XHR无法执行Cross-domain资源的读操作（支持写操作）,但只以为仅仅是不支持respose body的读操作而已，没想到连respose header的读操作也不支持。那怎么办呢？既然读操作不行那采用嵌套Cross-domain资源总行吧。然后有了以下的填坑过程:
1. 第一想到的就是嵌套iframe来实现，当iframe的实例化成本太高了，导致iframe还没来得及发送请求就已经完成unload过程了；
2. 于是想到了通过script发起请求, 因为respose body的内容不是有效脚本，因此会报脚本解析异常，若设置`type="text/tpl"`等内容时还不会发起网络请求；另外iframe、script等html元素均要加入DOM树后才能发起网络请求;
3. 最后想到HTMLImageElement，只要设置`src`属性则马上发起网络请求，而且返回非法内容导致解析失败时还是默默忍受，特别适合这次的任务:)
&emsp;于是得到下面的版本
```
;(function(exports){
  exports.Logout = Logout

  function Logout(url){
    if (this instanceof Logout);else return new Logout(url)
    this.url = url
  }
  Logout.prototype.exec = function(){
    var img = Image ? new Image() : document.createElement("IMG")
    img.src = this.url
  }
}(window))
```

## [before]unload导致性能下降？
&emsp;现在我们都明白如何利用`[before]unload`来做资源释放等善后工作了。
&emsp;但请记住一点：由于`[before]unload`事件会降低页面性能，因此仅由于需要做重要的善后或不可逆的清理工作时才监听这两个事件。
&emsp;以前，当我们从页面A跳转到页面B时，页面A的所有资源将被释放（销毁DOM对象,回收JS对象, 释放解码后的Image资源等）;后来各大浏览器厂商分别采用bfcache/page cache/fast history navigation机制，将页面A的状态保存到缓存中，当通过浏览器的后退/前进按钮跳转时马上从缓存中恢复页面，而不是重新实例化。以下情况将不被缓存起来：
1. 监听`unload`或`beforeunload`事件;
2. 响应头`Cache-Control: no-store`;
3. 对于采用HTTPS协议的响应头，满足以下一个或以上：
  3.1. `Cache-Control: no-cache`
  3.2. `Pragma: no-cache`
  3.3. 存在`Expires`超期的
4. 发生跳转时，页面存在未加载完的资源
5. 旗下iframe存在上述情况的
6. 页面在iframe中渲染，当用户修改iframe.src加载其他文档到该iframe时
&emsp;因此若执行不可逆的清理工作时，对于现代浏览器而言我们应该订阅`pagehide`事件，而不是`unload`事件，以便利用Page Cache机制。
事件发生顺序：`load`->`pageshow`->`pagehide`->`unload`
`pageshow`和`pagehide`的事件对象存在一个`persisted`属性，为true时表示从cache中恢复，false表示重新实例化。
&emsp;经简单测试发现chrome默认没有启用该特性，而Firefox则默认启用。实验代码：
```
// index.html
window.addEventListener('load', function(){
  console.log("index.load")
  window.test = true
})
window.addEventListener('pageshow', function(e){
  console.log("index.pageshow.persisted:" + e.persisted)
  console.log("index.test:" + window.test)
})

<a href="./next.html">next.html</a>
```
```
// next.html
window.addEventListener('load', function(){
  console.log("next.load")
})
window.addEventListener('pageshow', function(e){
  console.log("next.pageshow.persisted:" + e.persisted)
})
```
运行环境：FireFox
操作步骤：1.首先访问index.html，2.然后点击链接跳转到next.html，3.然后点击浏览器的回退按钮跳转到index.html，4.最后点击浏览器的前进按钮跳转到next.html。
输出结果：
```
// 1
index.load
index.pageshow.persisted:false
index.test:true
// 2
next.load
next.pageshow.persisted:false
// 3
index.pageshow.persisted:true
index.test:true
//4
next.pageshow.persisted:true
```
&emsp;看到页面是从bfcache恢复而来的，所以JS对象均未回收，因此`window.test`值依然有效。另外load仅在页面初始化后才会触发，因此从bfcache中恢复页面时并不会触发。
&emsp;假如在index.html上订阅了`unload`或`beforeunload`事件，那么该页面将不会保存到bfcache。
&emsp;另外通过jQuery.ready来监听页面初始化事件时，不用考虑bfcache的影响，因为它帮我们处理好了:)


## 总结
  若有纰漏望请指正，谢谢！
  尊重原创，转载请注明来自：肥子John

## 感谢
[window-onbeforeunload-not-working](http://stackoverflow.com/questions/7255649/window-onbeforeunload-not-working)
[beforeunload](https://developer.mozilla.org/en/docs/Web/Events/beforeunload)
[unload](https://developer.mozilla.org/en-US/docs/Web/Events/unload)
[prompt-to-unload-a-document](https://html.spec.whatwg.org/#prompt-to-unload-a-document)
[webkit page cache i - the basics](https://webkit.org/blog/427/webkit-page-cache-i-the-basics/)
[webkit page cache ii - the unload event](https://webkit.org/blog/516/webkit-page-cache-ii-the-unload-event/)
[pagehide](https://developer.mozilla.org/en-US/docs/Web/Events/pagehide)
[pageshow](https://developer.mozilla.org/en-US/docs/Web/Events/pageshow)
[Redirects Do’s and Don’ts](http://www.redirect-checker.org/redirects-dos-donts.php)
[Using_Firefox_1.5_c    aching#New_browser_events](https://developer.mozilla.org/en-US/Firefox/Releases/1.5/Using_Firefox_1.5_caching#New_browser_events)
[cross-browser-onload-event-and-the-back-button](http://stackoverflow.com/questions/158319/cross-browser-onload-event-and-the-back-button)
