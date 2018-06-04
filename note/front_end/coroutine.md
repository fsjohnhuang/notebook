Coroutine(协程)
&emsp;任务以coroutine的形式封装，一系列coroutine按次序在同一个Thread里执行，当某个coroutine处于block状态时，当前Thread不会被阻塞，而是将执行权交给非本系列coroutine的其他任务来使用。

完全在用户态线程执行，不涉及内核态因此性能较高。


Lua的协程全称为**协同式多线程(colllaborative multithreading)**

coroutine == fiber ?

调度/挂起/执行

subroutine(子例程)

