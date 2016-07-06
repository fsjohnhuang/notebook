Actions that invoke the `beforeunload` event:
1. navigating to another page directly in the address bar or via a link.
2. closing or refresh current page.
3. operating the location object of current page.
4. invocation of `window.navigate` method
5. invocation of `window.open` or `document.open` method to load a document in the same page.

### under Chromium
  error message `Blocked alert/prompt/confirm() during beforeunload/unload.` would come up, when we call alert,prompt and confirm method of Window object in beforeunload or unload event handler.
  if the return value of `beforeunload` event handler was null or undefined,the alert/prompt/confirm dialog would not show up. if the return value of `beforeunload` is the one except null or undefined, it would be as the text of confirm dialog before close/refresh the page.(caution: without invocation of alert, prompt or confirm method)
 method e.preventDefault does not work.
 IE is in the same way(event.returnValue = "<text>")

### under Firefox
  there is no response even error, when we call alert,prompt and confirm method of Window object in beforeunload or unload event handler.
  as long as the return value of `beforeunload` event handler is the one except of null/undefined, there would be confirm dialog show up before close or refresh the page.but no customized text of the confirm.
  method e.preventDefault does not work.

  it's ok to do request by ajax under beforeunload or unload.

>Since 25 May 2011, the HTML5 specification states that calls to `window.showModalDialog()`, `window.alert()`, `window.confirm()` and `window.prompt()` methods may be ignored during this event.
>You can and should handle this event through `window.addEventListener()` and the `beforeunload` event.

[](https://developer.mozilla.org/en-US/docs/Web/API/WindowEventHandlers/onbeforeunload#Notes)

### under Opera
  there is no `beforeunload` event

### under Mobile Browsers(Safari, Opera Mobile & mini)
  there is no `beforeunload` event, but support `unload`


DOM2 handler(addEventListener), return false would not prevent the default.
Microsoft DOM2-ish handler(attachEvent), `event.returnValue` is false would prevent the default.
DOM0 handler(onclick=""), return false would prevent the default.



### [Microsoft DOM2-ish](https://msdn.microsoft.com/en-us/library/ms536343(VS.85).aspx)
ie8-10
#### `object.attachEvent(event:string, pDisp:function):boolean`
`pDisp:function`, event handler.
  attach multiple functions to the same event on the same object, functions are called in random order.
  detach event listener by  `object.detachEvent(event:string, pDisp:function)`, could not detach all event listener by `object.detachEvent(event:string)`
#### `document.createEventObject(pvarEventObject?:object):Event`
`pvarEventObject`, an object that specifies an existing event object on which to base the new object. null or undefined to specify a new, blan event object.
  Generates an event object to pass event context info when use the `object.fireEvent` method.
#### ``

## The Page Cache
[webkit-page-cache-i-the-basics](https://webkit.org/blog/427/webkit-page-cache-i-the-basics/)


session history entry
