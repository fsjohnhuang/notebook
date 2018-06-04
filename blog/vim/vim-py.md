# 让VIM支持Python2 by update-alternatives
## 前言
&emsp;Ubuntu 16+中`$ sudo apt install vim`所安装的vim只支持Python3，但很多插件如YCM和powerline均需要Python2，那就来场“生命贵在折腾”吧！

## 自检
&emsp;在shell中输入以下命令，若出现`-python`则表示不支持Python2，`+python`则表示支持;`-python3`表示不支持Python3，`+python3`则表示支持。
```
$ vim --version | grep python
```

## 安装
1.安装
```
$ sudo apt install vim-nox-py2
```
除了`vim-nox-py2`，还可以选择安装`vim-gtk-py2`等。
2.重置vim符号链接
```
$ sudo update-alternatives --config vim
```
![](./update-alternatives.png)
然后输入0按回车。现在输入`$ vim`，打开的就是`/usr/bin/vim.nox-py2`这个vim版本了！

## 八一八`update-alternatives`
&emsp;在Debian系统中(含Ubuntu)我们可能会安装很多功能相似的程序，如emacs和vim，甚至同一个程序安装多个版本，如vim-nox和vim-nox-py2。但在一般使用场景下我们仅使用固定某个或某版本的程序，那么通过`update-alternatives`命令来管理系统命令符号链接，我们就能轻松完成如将vim从指向vim-nox切换为指向vim-nox-py2，甚至一次性将`java`和`javac`从指向1.4切换为指向1.8，而不是到`/usr/bin/`中逐个符号链接修改那么蛋碎。

### 组成
link，符号链接绝对路径，如`/usr/bin/vim`;
name, 位于`/etc/alternative/`下的文件名称，作为update-alternatives命令中使用的命令标识;
path, 实际程序的执行路径, 如`/usr/bin/vim.nox-py2`.
priority, 若处于auto mode，那么priority值高的将作为符号链接的默认目标值.
&emsp;其中前三者的关系是：
```
$ ln -s /usr/bin/vim.nox-py2 /etc/alternative/vim 
$ ln -s /etc/alternative/vim /usr/bin/vim
```

### 命令API
1.查看命令符号链接组信息, `update-alternatives --display <name>`
示例：`update-alternatives --display vim`
![](./update-alternatives-display.png)
可以看到现在处于manual mode，若处于auto mode，那么priority值高的将作为符号链接的目标值。
上图中`/usr/bin/vim.gtk`的priority值最高，因此若处于auto mode时，应该为`ln -s /usr/bin/vim.gtk /etc/alternative/vim`。但由于现在处理manual mode，因此可以看到这个提示：
```
link best version is /usr/bin/vim.gtk
link currently points to /usr/bin/vim.gtk-py2
```

2.选择符号链接的目标值, `update-alternatives --config <name>`
示例：`sudo update-alternatives --config vim`
![](./update-alternatives-config.png)

3.新增替换的记录, `update-alternatives --install <link> <name> <path> <priority> [--slave <link> <name> <path>] ...`
示例：
```
$ sudo update-alternatives --install /usr/bin/java java /usr/local/jre1.6.0_20/bin/java 100 –slave /usr/bin/javac javac /usr/local/jre1.6.0_20/bin/javac
```

4.删除替换组的记录, `update-alternatives --remove <name> <path>`
示例：
```
$ sudo update-alternatives --remove vim /usr/bin/vim.gtk-py2
```
5.删除替换组的记录, `update-alternatives --remove-all <name>`
6.切换模式, `update-alternatives --auto <name>`
而当通过`update-alternatives --config <name>`设置默认目标后，该替换组的模式即会变为manual mode。

## 总结
&emsp;尊重原创，转载请注明来自：肥仔John^_^
