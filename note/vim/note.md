
## 换行符
windows的换行符是`\r\n`,linux是`\n`，而mac是`\r`。
当使用ex的替换命令时`s/a/b/`，a中的换行符根据上述对应的即可，而b中的换行符统一采用`\r`来指定，然后vim会根据fileformat的设置采用相应的换行符。
```
set fileformat=unix
set fileformat=dos
"缩写set ff=unix
"缩写set ff=dos
```
### 示例
1. 从windows中复制文档到linux下发现
```
第一行
^M
第二行
^M
```
上述`^M`为windows下的换行符`\r\n`，要替换为linux的`\n`。采用`:%s/\r\n/\r/g`
2. 在linux下采用windows的换行符
`:set ff=dos`
`:s/$/\r/g`
