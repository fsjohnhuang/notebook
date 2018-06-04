##Table of Content
1. Communication between cross-domain iframes
  1.1. by `Window.postMessage()`
  1.2. by `Location.href` with hash
  1.3. change to the same origin by setting `Document.domain`
2. Self-adaptive iframe element.
3. Downside of Iframe
  3.1. increase the loading time of top window
  3.2. share the socket pool of top window
  3.3. require a lot of memory

## HTML Element
```
@prop 
```



##1.Communication between cross-domain iframes
### 1.1. by `Window.postMessage()`
Message Send API
`otherWindow.postMessage(message:any, targetOrigin:string, [transfer])`
caution: the event handler would be executed in the next event loop.so the pending script would be executed completes.
```
$('#foo').click(function(){
  otherWin.postMessage({data: 1}, "*")
  for (var i = 0; i < 50000000; ++i);
  console.log("pending scripts are executed completes.")
})
```

`message:any, data to be sent to the other window.`
`targetOrigin:string,set "*" or URI as value, if the origin(protocol, hostname and port) of the otherWindow doesn't match the targetOrigin, the MessageEvent will not be dispatched`
`transfer:Transferable[]`, the ownership is given to the otherWindow.


Message Receive API
`window.addEventListener('message', eventHandler, false)`


MessageEvent
`data:any, the message argument of postMessage`
`origin:string, the origin of the sender window when the postMessage is called,no guarantees to the current or future origin of otherWindow`
`source:Window, the sender window`

origin is for IDN host name only

IDN(Internationalized Domain Name)
punycode

Compatibility
IE8+, but don't support `transfer argument`

Ref
(Window.postMessage())[https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessagehhkj]
