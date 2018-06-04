出现跨文档的节点操作时，抛出WRONG_DOCUMENT_ERR: DOM Exception 4的异常

IE11上发生

W3C DomException中定义了WRONG_DOCUMENT_ERR额含义，参考:http://reference.sitepoint.com/javascript/DOMException

通过document.importNode或cloneNode复制节点后再操作。
