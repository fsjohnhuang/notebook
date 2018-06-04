win32 用于绘制窗体、按钮、对话框等用户交互界面，并管理当前系统运行的进程、硬件系统状态监视等的一套windows核心的动态链接库。（注意：win32 API是用C写的）

## 分类
1.窗体管理
2.窗体通用控制
3.Shell特性
4.图形设备接口
5.系统服务
6.国际特性
7.网络服务

## Windows程序开发发展过程
win16/win32函数 -> COM -> COM+ -> .NET Framework

1.win16/win32函数，用户和开发人员直接使用win16/win32函数编写程序
2.COM，C++的OO能力将win16/win32函数分类打包为COM并安装在系统上，供用户和开发人员使用。MFC(Microsoft)和OWL(Borland)就是使用COM来编程。
3..NET Framework则以程序集(Assembly)的形式对win16/win32作封装。
常用的dll文件为：
User32.dll
Kernel32.dll

C版本示例：
```
#include <windows.h>

// WINAPI是宏，用于表示调用win32api，实际值为__stdcall
int WINAPI WinMain(HINSTANCE hInstance,
         HINSTANCE hPrevInstance,
         PSTR szCmdLine,
         int iCmdShow)
 {
   MessageBox(NULL, TEXT("Hello,Win32!"), TEXT("问候"), MB_OK);
   MessageBox(NULL, L"Hello,Win32!", L"问候", 0);
 }
```


FindWindow，根据class name或window name在桌面窗体下查找窗体
EnumChildWindows(hWnd hWndParent)


## C#调用win32 api
```
using System;
using System.Runtime.InteropServices;

class Program{
  // 指定要调用的API所在的dll文件
  [DllImport("User32.dll")]
  public static extern int MessageBox(int h, string m, string c, int type);

  public static int main(){
    MessageBox(0, "Hi", "fsjohnhuang", 4);
    Console.ReadLine();
    return 0;
  }
}
```

其实.net framework已经对win32 api进行封装，因此只需使用winform的库即可。如限制鼠标移动范围:
```
private void Form1_DoubleClick(object sender, EventArgs e){
  Rectangle r = new Rectangle(this.Left, this.Top, this.Width, this.Height);
  System.Windows.Forms.Cursor.Clip = r;
}
```
而win32中则要使用ClipCursor函数
