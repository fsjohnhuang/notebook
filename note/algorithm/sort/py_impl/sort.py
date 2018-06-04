#!/usr/bin/python
#-*- coding:utf-8 -*-
'''
REF
[十大经典排序算法](http://www.cnblogs.com/chunguang/p/5892768.html)
'''

'''
冒泡排序
思路：
  遍历序列n次,每次遍历的序列长度递减，且每次遍历均找出当前序列中最大或最小值。
复杂度：
  n(n-1)/2 简化为 n^2
稳定性：高
'''
'''
  每次遍历都确定本次遍历中的最大值
  最后则会最小值将会浮出来
'''
def bubble_sort1(list):
    count = len(list)
    for i in range(0, count):
        for j in range(0, count - i):
            if j + 1 < count - i and list[j] > list[j+1]:
                list[j],list[j+1] = list[j+1],list[j]
    return list

'''
  每次遍历都确定本次遍历中的最小值
  最后则会最大值将会浮出来
'''
def bubble_sort2(list):
    count = len(list)
    for i in range(0, count):
        for j in range(i + 1, count):
            if list[i] > list[j]:
                list[i], list[j] = list[j], list[i]
    return list

#list = [2,3,1,4]
#print bubble_sort1(list)
#print bubble_sort2(list)

'''
插入排序
思路：
  将序列分为两组，一组是已排序，另一组为未排序。然后从未排序的一组取出一个元素，然后将该元素插入到已排序一组适当的位置。
复杂度：
  n(n-1)/2 简化为 n^2
稳定性：高
'''
def insert_sort(list):
    count = len(list)
    for end_of_order in range(0, count - 1):
        start_of_disorder = end_of_order + 1
        while end_of_order >= 0 and list[end_of_order] > list[start_of_disorder]:
            list[end_of_order], list[start_of_disorder] = list[start_of_disorder], list[end_of_order]
            end_of_order -= 1
            start_of_disorder -= 1
    return list

#list = [2,3,1,4]
#print insert_sort(list)


'''
选择排序
思路：
  将序列分为两组，一组是已排序，另一组为未排序。然后从未排序的一组中取出最小或最大的元素，然后将起追加到已排序的一组的末尾。
复杂度：
  n(n-1)/2 简化为 n^2
稳定性：高
'''
def selection_sort(list):
    count = len(list)
    end_of_order = -1
    start_of_disorder = 0
    while end_of_order < count:
        for i in range(start_of_disorder + 1, count):
            if list[start_of_disorder] > list[i]:
                list[start_of_disorder], list[i] = list[i], list[start_of_disorder]
        end_of_order = start_of_disorder
        start_of_disorder += 1
    return list

#list = [2,3,1,4]
#print selection_sort(list)

import test
