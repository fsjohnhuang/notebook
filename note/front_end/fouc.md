# FOUC(flash of unstyled content)
浏览器样式闪烁，happen in older version ie
## Situation/Definition
  a web page appears briefly with the browser's default styles prior to loading an external CSS stylesheet, due to the web browser engine rendering the page before all the information is retrieved.And then the page corrects itself as soon as the style rules are loaded and applied.

## Reason
  the browser builds the Document Object Model on-the-fly and may choose to display the text first which could be parsed quickest. when after the ancillary files(such as css files) referenced in the markup have downloaded,the brower would rerender the document.


## Solution
### Chrome
  `<link rel="stylesheet">`,`<link rel="import">` and `@import url("<url>")`would block rendering as `<script></script>` do.(wouldn't block the request for other resources such as img, script, link, @import url etc.)

block rendering means img wouldn't show even if it has been loaded, script and style wouldn't executed even if has been loaded.
## Block Parsing
```
<html>
  <head></head>
  <body>
    <script>
      console.log(document.getElementById('hi'))
    </script>
    <script src="./longtime.js"></script>
    <div id="hi">Hi</div>
  </body>
</html>
```
while script is loading, print `null` in console.

## Block Rendering
```
<html>
  <head></head>
  <body>
    <script>
      console.log(document.getElementById('hi'))
    </script>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
while link is loading, would print `<div id="hi">Hi</div>` in console.

```
<html>
  <head>
    <script>
      console.log('hi' + document.getElementById('hi'))
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
while link is loading, would print info below in console.
```
hi + null
s + script#s
```

Affects:
1. the css stylesheet and script(which are later) would not be executed even if the resource has loaded and it could be found in the DOM tree.
2. if the block rendering occur in head, the body's children have not be initialized.
3. the whole page would not be rendered, until the css stylesheets have been downloaded all.(in firefox the stylesheet before the block rendering stylesheet would applied, and if the block rendering occur in head, the body's children would display)
In firefox 
```
<html>
  <head>
  </head>
  <body>
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
`<div id="hi">Hi</div>` displayed with `color:red`
```
<html>
  <head>
  </head>
  <body>
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
    <script></script>
    <div id="hi">Hi</div>
  </body>
</html>
or
<html>
  <head>
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
  </head>
  <body>
    <div id="hi">Hi</div>
  </body>
</html>
```
nothing would be display.

In IE
```
<html>
  <head>
  </head>
  <body>
    <style>#hi{color:red;}</style>
    <link rel="stylesheet" href="./longtime.css">
    <div id="hi">Hi</div>
  </body>
</html>
```
display nothinig, and div#hi is not in DOM
```
<html>
  <head>
  </head>
  <body>
    <style>#hi{color:red;}</style>
    <div id="hi">Hi</div>
    <link rel="stylesheet" href="./longtime.css">
  </body>
</html>
```
display div#hi with style

The request of resource such as `img`,`script`,`link`,`@import url()` would be block under **Block Rendering/Parsing**.

solution:
```
<html class="no-js">
	<style type="text/less">
		/*modernizr会将html的no-js替换为js，并将modernizr代码在最后时加载，那么就能保证所有样式文件已经加载完成*/
		.js{
			.wrapper{
				....
			}
		}
	</style>
	<body>
		<div class="wrapper"></div>
		<script src="modernizr.js"></script>
	</body>
</html>
```

## Ref
[Flash of unstyled content](https://en.wikipedia.org/wiki/Flash_of_unstyled_content)
[The FOUC Problem](https://webkit.org/blog/66/the-fouc-problem/)
[Critical rendering path](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/?hl=en)
