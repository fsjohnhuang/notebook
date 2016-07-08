
[Same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)

origin consist of __protocol__, __port__ and __host/domain__.
IE Exceptions
origin of IE doesn't include port.(e.g. `http://test.com:80/` and `http://test.com:81/` are considered from same origin and no restrictions are applied)
if both domains are in __Trust Zone__, then the same origin limitaions are not applied.

restrictions
1. Cross-domain writes are allowed.
  links,scripts,redirects,form submissions and send request to server by ajax are allowed, but can not receive response and response headers from server.
  so ajax would not redirect when do cross-domain request, even the HTTP status code is 302/301.
2. Cross-domain embedding is allowed.
3. Cross-domain reads are not allowed.

## Cross-domain Embedding
1. `<script src=""></script>`
  share the same global execute context, JSONP is base on this one.
2. `<link rel="stylesheet" href="...">`
  allow to load stylesheets from different origins, but not allow to access the CSSOM default.
3. `<img>`
4. Media files with `<video>` and `<audio>`
5. Plug-ins with `<object>`,`<embed>` and `<applet>`
6. Fonts with `@font-face`, some browsers allow but others require same-origin.
7. `<frame>` and `<iframe>`, use [X-Frame-Options](https://developer.mozilla.org/en-US/docs/HTTP/X-Frame-Options) header to prevent this form of cross-origin interaction.
[X-Frame-Options response header](https://tools.ietf.org/html/rfc7034), is to indicate to render the page in `<frame>`,`<iframe>` or `<object>` whether or not.Avoid [clickjacking](https://en.wikipedia.org/wiki/Clickjacking) attacks by enabling this header.
X-Frame-Options: DENY | SAMEORIGIN | ALLOW-FROM <uri>
Browser compatibility
IE8+
communication between iframes invokes cross-domain issues.
if domains differ, iframes cannot interact with each other e.g. exec js, modify DOM etc.

H5 provides a [sandbox property](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe) to re-enable particular features of the cross-domain iframe interaction.

## Cross-domain JavaScript API
  Allow documents have limited access privilege to Window and Location objects.
There are two ways for windows' communication.
1. window.postMessage
2. window.location.href


## Client Storages Related to Origin
  LocalStorage and IndexedDB are separated by origin. JavaScript in one origin can not read from or write to the storage belonging to another origin.
  Cookies use a separated definition of origins. JavaScript in one origin can read from or write to the cookies belonging to the same or superdomain, as long as the parent domain is not a [public suffix](https://publicsuffix.org/).
Cautions:
1. Cookies accessing regardless the protocol and port, just according the domain.
2. Limit cookie's availability using the Domain, Path, Secure and Http-Only flags when set cookie.
3. We can not peek the Domain,Path,Secure flags when read the cookies.
4. JavaScript in http/https can access cookies in https/http.


[File Uri Scheme](https://developer.mozilla.org/en-US/docs/Same-origin_policy_for_file:_URIs)
prefix of uri is like `file:///`.

Chrome
  the `document.domain` of originating file would be `null`, and reports cross-domain issue when access other file's HTMLDocument element.Accessing the same file is denied even.
**How to set?**
`chrome --disable-web-security #unix/linux only`
`chrome --allow-file-access-from-files`
[File Url Cross Domain Issue in Chrome- Unexpected](http://stackoverflow.com/questions/6060786/file-url-cross-domain-issue-in-chrome-unexpected)

FireFox
  In Gecko 1.8 or earlier, any HTML file on local disk could read any other file on the local disk. It means there is no cross-domain issues.
  Starting in Gecko 1.9, a file can read anther file only if the parent of the originating file is an ancestor directory of the target file.

preference `security.fileuri.strict_origin_policy`(default value is `true`) determines apply the cross-origin policy for local files whether or not.
**How to set?**
1. In a new tab, type `about:config` in the addr bar;
2. type `security.fileuri.strict_origin_policy` in the search box;
3. double-click the filtered item to toggle it to false or true.

About Uri Scheme(e.g. `about:blank`) and JavaScript Uri Scheme(e.g. `javascript:...`) inherit the origin from the document that loaded the URI.
Data Uri Scheme(e.g. `data:...`) would create a new, empty, security context.

Q: the relation of origin and domain?
change origin
`document.domain="<superdomain of current domain>"`
caution: 
1. can not set the top-level domain as value.(e.g. `document.domain="com"` is illegal)
2. if `document.domain` is successfully set, the port part is also set to null.


[CORS(Cross-Origin Resource Sharing)](https://www.w3.org/TR/cors/)
W3C and Web Application Working Group recommends CORS mechanism.
__web servers__ controls the cross-domain access, which enable secure cross-domain data transfers.
enable cross-site HTTP request for:
1. Invocation of the XMLHttpRequest API in a cross-site manner.
2. Web Fonts.
3. WebGL textures.
4. Images/video frames drawn to a canvas using drawimage.
5. CSSOM access.
6. Scripts

Simple Requests
methods: GET | HEAD | POST
manually set headers: Accept,Accept-Language, Content-Type, Content-Language
value of Content-Type: applicatoin/x-www-form-urlencoded | multipart/form-data | text/plain

Preflighted Requests, soliciting supported methods from the server with an HTTP OPTIONS request method by browsers. Server can notify clients to request with credentials or not.
a request is preflight if:
1. HTTP request method is other than GET, HEAD or POST.
2. HTTP request method is POST, but Content-Type is other than text/plain, application/x-www-form-ulrencoded or multipart/form-data.
3. It sets custom headers in the request.(e.g. X-SomeCustomHeaders)

OPTIONS is an HTTP/1.1 method, is used to determine further info from servers.

### Respons Headers
`Access-Control-Allow-Origin: <origin>`
<origin>: * | <protocol>://<host>[:<port>]

`Access-Control-Allow-Credentials: true|false`
  if this header is true, the Access-Control-Allow-Origin header should be exact domain.
  1. when simple request with credentials, this header indicates expose the response to the requester whether or not.
  2. when reponse to preflighted request with this header, indicates the actual request can be made using credentials.
```
var xhr = new XMLHttpRequest()
var url = ''
xhr.open('GET', url, true)
xhr.withCredentials = true
xhr.onreadystatechange = function(){}
xhr.send()
```

`Access-Control-Expose-Headers: <header>[,<header>]*`, list the custom headers which can be accessed from browsers.

related to preflight
`Access-Control-Allow-Methods: <method>[,<method>]*` 
`Access-Control-Allow-Headers: <header>[,<header>]*` 
`Access-Control-Max-Age: <delta-second>`, indicates how long the response to the preflight request can be cached for without sending another preflight request. Every browser has a maximum interval value which is prior than value of this header.

### Request Headers
`Origin: <origin>`
`Access-Control-Request-Method: <method>`
`Access-Control-Request-Headers: <header>[,<header>]*`

### XMLHttpRequest & Fetch API
[Fetch](https://fetch.spec.whatwg.org/)

### window.postMessage and location.href

### Cookies manipulation from client & server, and the tranferation

### XSS

### clickhijack

[CSRF(Cross-Site Request Forgery)](https://www.owasp.org/index.php/Cross-Site_Request_Forgery_%28CSRF%29)
  Forces an end user to execute unwanted action on a web application in which they are currently authenticated.It targets state-changing requests other than theft of data.(e.g. changing email addr, transferring funds)


[Header Definitions](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.7)
[HTML](https://html.spec.whatwg.org/multipage/browsers.html)
[Attack](https://www.owasp.org/index.php/Category:Attack)
