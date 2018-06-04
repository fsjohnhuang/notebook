
```
import win32api, win32con

# 获取现实屏幕尺寸
width = win32api.GetSystemMetrics(win32con.SM_CXSCREEN)
height = win32api.GetSystemMetrics(win32con.SM_CYSCREEN)

hWnd = win32gui.FindWindow("sdsf", None)
# 最小化窗体
win32gui.CloseWindow(hWnd)
# 关闭窗体
hWnd.SendMessage(win32con.WM_CLOSE)

```

```
import ImageGrab

# 全屏截图
img = ImageGrab.grab()
# 局部截图，left,top,right,bottom
bbox = (0,0,200, 100)
img = ImageGrab.grab(bbox)

# 捉取剪贴板的快照
# 若剪贴板中不是图片数据或图片路径则返回None
img = ImageGrab.grabclipboard()
if isinstance(img, Image.Image):
  print "OK"
elif im:
  for filename in img:
    try:
      Image.open(filename)
    except IOError:
    else: print "OK"
else:
  print "empty"
```
