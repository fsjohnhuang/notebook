
## 示例1
```
import Image

infile = "/home/john/1.jpg"

# 创建Image实例，文件无法打开则抛IOError
# 调用open后，只会读取文件的format,size,mode等头信息，而其他信息均延迟读取
try:
    im = Image.open(infile)
except IOError:
    print("cannot convert", infile)

# format 图片格式，若不是从disk上读取则返回None
# size为(宽,高)
# mode为色彩模式，L(luminance)灰度图，RGB为真彩图，CMYK为印刷用
print(im.format, im.size, im.mode)

# 临时存储图像，然后调用xv来创建窗体显示图像
im.show()

# 保存图片，默认会采用文件扩展名来决定图片格式
im.save("/home/john/2.jpg")
```

## 示例2——Thumbnails
```
import os, sys
import Image

infile = "/home/john/1.jpg"
thumbnailSize = 128, 128

try:
    im = Image.open(infile)
    im.thumbnail(thumbnailSize)
    im.show()
except IOError:
    pass

```
