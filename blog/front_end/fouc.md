#前端魔法堂：解秘FOUC
## 前言
&emsp;对于问题多多的IE678，FOUC(flash of unstyled content)——浏览器样式闪烁是一个不可忽视的话题，但对于ever green的浏览器就不用理会了吗？下面尝试较全面地解密FOUC。
## 到底什么是FOUC？
&emsp;页面加载解析时，页面以样式A渲染；当页面加载解析完成后，页面突然以样式B渲染，导致出现页面样式闪烁。
&emsp;样式A，浏览器默认样式 或 浏览器默认样式 层叠 部分已加载的页面样式；
&emsp;样式B，浏览器默认样式 叠加 全部页面样式。
## 为什么会出现FOUC
&emsp;我们了解当输入网址按回车后浏览器会向服务器发送请求，然后服务器返回页面给浏览器，浏览器边下载页面边解析边渲染。
下面我们解剖一下边下载页面边解析边渲染的过程:
1. 边下载边解析就是边下载html边构建DOM Tree;
2. 浏览器以user agent stylesheet(浏览器内置样式)为原料构建CSSOM Tree;
3. DOM Tree+CSSOM Tree构建出Render Tree，然后页面内容渲染出来;
4. 当解析到inline stylesheet 或 internal stylesheet时，马上刷新CSSOM Tree，CSSOM Tree或DOM Tree发生变化时会引起Render Tree变化;
5. 当解析到external stylesheet时就先加载，然后如internal stylesheet那样解析和刷新CSSOM Tree和Render Tree了。
&emsp;上述步骤5中由于样式文件存在下载这个延时不确定的阶段，因此网络环境不好或样式资源体积大的情况下我们可以看到样式闪烁明显。
&emsp;这就是为什么我们将external stylesheet的引入放在`head`标签中的原因，在`body`渲染前先把相对完整的CSSOM Tree构建好。但大家都听说过`script`会阻塞html页面解析(block parsing)，而`link`不会，那假如网络环境不好或样式资源体积大时，`body`已经解析并加入到DOM Tree后，external stylesheet才加载完成，不是也会造成FOUC吗？<br>
&emsp;`style`,`link`等样式资源的下载、解析确实不会阻塞页面的解析，但它们会阻塞页面的渲染(block rendering)。

## Block Parsing 和 Block Rendering的区别
Block Parsing: 阻塞HTML页面解析，HTML页面会被继续下载，但阻塞点后面的标签不会被解析，`img`,`link`等不会发请求获取外部资源。
Block Rendering:阻塞HTML页面渲染，HTML页面会被继续下载，阻塞点后面的标签会继续被解析，`img`,`link`等会继续发送请求获取外部资源，但不会合成Rendering Tree或不会触发页面渲染，也不会执行JavaScript代码。
&emsp;各浏览器这方面还有一点差异：
### 对于Chrome
`<link rel="stylesheet">`,`<link rel="import">` and `@import url("<url>")`会阻塞渲染。
示例1：阻塞解析
```
<html>
  <body>
    <script>
			// 打印出 null
      console.log(document.getElementById('hi'))
    </script>
    <script src="./longtime.js"></script>
    <div id="hi">Hi</div>
  </body>
</html>
```
示例2：阻塞渲染
```
<html>
  <body>
    <script>
			// 打印出 <div id="hi">Hi</div>
      console.log(document.getElementById('hi'))
    </script>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
示例3：阻塞渲染
```
<html>
  <head>
    <script>
			// 打印出 hinull
      console.log('hi' + document.getElementById('hi'))
			// 打印出 hiscript#s
      console.log('s' + document.getElementById('s'))
    </script>
    <link rel="stylesheet" href="./longtime.css">
    <script id="s"></script>
  </head>
  <body>
    <div id="hi">Hi</div>
  </body>
</html>
```
示例4：阻塞渲染
```
<html>
  <body>
		<!-- div#hi在 ./longtime.css下载完前不会被渲染 -->
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
示例2说明，如果阻塞渲染发生在`body`标签内，那么`body`及其子元素会继续解析并追加到DOM Tree中;
示例3说明，如果阻塞渲染发生在`head`标签内，那么`body`及其子元素不会被追加到DOM Tree中。
示例4说明，不管external stylesheet在哪里引入，在页面的所有external stylesheets下载完成前，整个页面将不会被渲染。(估计Chrome会预先统计external stylesheet的数量)
### 对于FireFox
示例1：阻塞渲染
```
<html>
  <body>
		<!-- div#hi的文字显示为红色，待./longtime.css下载完后又渲染为其他颜色 -->
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
示例2：阻塞渲染
```
<html>
  <head>
		<!-- div#hi不显示，直到./longtime.css下载完后 -->
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
  </head>
  <body>
    <div id="hi">Hi</div>
  </body>
</html>
```
### 对于IE9
示例1：
```
<html>
  <body>
		<!-- div#hi没有渲染，也没有加入到DOM Tree中 -->
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
示例2：
```
<html>
  <body>
		<!-- div#hi渲染了，加入到DOM Tree中 -->
    <style>#hi{color:red;}</style>
    <div id="hi">Hi</div>
    <link rel="stylesheet" href="./longtime.css">
  </body>
</html>
```
上面的示例表明，IE下block rendering等价于block parsing，因为连`img`,`script`,`link`,`@import url()`资源请求都会被阻塞。

## 解决方法
&emsp;现在我们知道FOUC时由于页面采用临时样式来渲染页面而导致的，其中仅有chrome能好的屏蔽了这一点，而其他浏览器就呵呵了。那有什么方案可以解决呢？其实我们的目的就是不要让用户看到临时样式，那么我们可以隐藏`body`，当样式资源加载完成后再显示`body`。
```
<html class="no-js">
	<style>
		/*modernizr会将html的no-js替换为js，并将modernizr代码在最后时加载，那么就能保证所有样式文件已经加载完成*/
		.no-js body{display: none!important;}
	</style>
	<body>
		<script src="modernizr.js"></script>
	</body>
</html>
```
(编译modernizr时记得勾setClasses哦，否则不会替换no-js的！)

## 总结
&emsp;上述方案虽然解决了FOUC的问题，但很明显地延长了首屏白屏时间，当前较流行的App Shell(可以理解为先显示页面布局的骨架或一幅图片)也会失效，所以对于2C的应用仅仅采用上述的方案效果并不理想。后续待我研究好后再追加一篇吧^_^
&emsp;尊重原创，转载请注明来自：^_^肥仔John

## 感谢
[Flash of unstyled content](https://en.wikipedia.org/wiki/Flash_of_unstyled_content)
[The FOUC Problem](https://webkit.org/blog/66/the-fouc-problem/)
[Critical rendering path](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/?hl=en)
