from PIL import Image, ImageDraw,ImageFont, ImageFilter
import random

# 随机字母
def rndChar():
    return chr(random.randint(65, 90))

# 随机颜色1
def rndColor1():
    return (random.randint(64, 255), random.randint(64, 255), random.randint(64, 255))


# 随机颜色2
def rndColor2():
    return (random.randint(32, 127), random.randint(32, 127), random.randint(32, 127))

w,h = bbox = (240, 60)
im = Image.new('RGB', bbox, (255,255,255))
# 创建Font对象
font = ImageFont.truetype('Arial.ttf', 36)
# 创建Draw对象
draw = ImageDraw.Draw(im)
# 着色每个像素
for y in xrange(h):
    for x in xrange(w):
        draw.point((x,y), fill=rndColor1())
# 输出文字
for t in xrange(4):
    draw.text((60 * t + 10, 10), rndChar(), font=font, fill=rndColor2())
# 表面模糊
im = im.filter(ImageFilter.BLUR)
im.save('code.jpg', 'jpeg')
