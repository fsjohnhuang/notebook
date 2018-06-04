# HTC(HTML Component) 
obsolete as of IE10 
.htc extension name, MIME is text/x-component

HTC file
JScript,HTML,Specific Markup

custom attribute, method, event

usage
```
<style>
    #btn{
        behavior: url(Btn.htc) url(Color.htc);
    }
</style>
<button id="btn"></button>
```

definition
speicific markup is for interface definition
```
<PUBLIC:COMPONENT></PUBLIC:COMPONENT>

// attach event
<PUBLIC:ATTACH EVENT="" ONEVENT=""></PUBLIC:ATTACH>
EVENT, event name, e.g. EVENT="onclick"
ONEVENT, event handler, e.g. ONEVENT="clickhandler()"
FOR, attach event of something, e.g. window

// define public property, could override native property,e.g. href property of a element.
<PUBLIC:PROPERTY NAME=""></PUBLIC:PROPERTY>
NAME, attribute name
INTERNALNAME, 
PUT, getter function
SET, setter function

// define public method
<PUBLIC:METHOD NAME=""></PUBLIC:METHOD>
NAME, method name

// define public custom event
<PUBLIC:EVENT ID="" NAME=""></PUBLIC:EVENT>
NAME, event name, e.g. onpush
ID, inner identity, e.g. push, call push.fire() would trigger onpush event
oEvt = createEventObject()
oEvt.result = {data:12}
eventid.fire(oEvt)
```
Implementation is by JScript

Lifycycle event
onreadystatechange, the value of event.readyState truns to 'complete' when the behavior becomes available.
ondocumentready, is recieved when the containing document has been loaded completely.
oncontentready, is recieved when the content of the element has been parsed.so we could access the innerHTML property of the element to return the correct value.

Global object
element, the element to attach
runtimeStyle, is short for element.runtimeStyle
event, event object

createEventObject()

custom element
```
<html xmlns:docjs>
<style>
docjs\:right{behavior:url(right.htc);}
</style>
<docjs:right></docjs:right>
</html>
```

Q:
1. multiple xml namespace?

## REF
https://msdn.microsoft.com/en-us/library/ms532146.aspx
https://msdn.microsoft.com/en-us/library/ms531018.aspx
