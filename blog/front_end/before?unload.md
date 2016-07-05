# JS魔法堂:[before]unload事件启示录
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

### `beforeunload`和`unload`的兼容性


## 防数据丢失机制——二次确认

### 坑1: `HTMLElement.addEventListener`事件绑定
### 坑2: 被`window.alert/confirm/prompt/showModalDialog`无视
### 坑3: 尊重用户的选择


## 总结
  尊重原创，转载请注明来自：肥子John

## 感谢
[window-onbeforeunload-not-working](http://stackoverflow.com/questions/7255649/window-onbeforeunload-not-working)
