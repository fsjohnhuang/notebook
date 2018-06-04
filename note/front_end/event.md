# DOM0 Event
```
ele.onclick = function(evt){
  // This is DOM0 Event Model
}
```


# DOM2 Event
## Browser Support
IE9+

#
```
@method document.createEvent
@description create an Event instance
@return {Event}

@method Event#initEvent
@param {String} eventName
@parma {Boolean} canBubble
@param {Boolean} preventDefault

@method Event#initMouseEvent
@param {String} eventName
@parma {Boolean} canBubble
@param {Boolean} preventDefault

@method Event#initUIEvent
@param {String} eventName
@parma {Boolean} canBubble
@param {Boolean} preventDefault
```

## Usage
```
let evt = document.createEvent()
evt.initEvent()
ele.dispatch(evt)
```
