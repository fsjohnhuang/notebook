## 冒泡排序
### 思路
&emsp;遍历序列，每次比较(相邻)两个元素的大小，若发现不相等则交换两者位置。
### 实现
```
def bubble_sort(list):
  count = len(lists)
  for i in range(0, count):
    for j in range(0, count-i):
      if list[j] > list[j+1]:
        list[j],list[j+1] = list[j+1],list[j]
  return list
```
### 复杂度

桶排序(Bucket Sort)

插入排序
希尔排序
快速排序
直接选择排序
堆排序
归并排序
基数排序

#REF
http://python.jobbole.com/82270/
