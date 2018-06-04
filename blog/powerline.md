# 让BASH,VIM美美的Powerline
## 前言
&emsp;鉴于BASH及其周边强大的工具以及VIM高效快捷，加上现在我工作重心转移到前端开发上，因此我华丽地转向Linux阵营(当然从最傻瓜式的Ubuntu开始啦!)。但BASH和VIM默认样式确实颜值太低，功能强大固然重要，但在这看脸的时代谁不爱美呢？那么我们先拿状态栏来开刀吧，而刀就是强大酷炫的Powerline本尊了。

## Powerline是什么?
&emsp;Powerline是个stateless status line,即可以配置到BASH,ZSH,VIM等上，而不像vim-powerline那样仅能用于vim.
### 安装Powerline
1.先保证python版本在2.7+
```
$ python --version
```
2.安装pip,并通过pip安装powerline
```
$ sudo apt install pip
$ pip install powerline-status
```
### 安装/配置字体
&emsp;说起样式怎能少了字体呢？而且Powerline中还用到特殊的字符，需要特定的字体来配合才能达到最佳显示效果。
```
$ git clone https://github.com/powerline/fonts &&
./fonts/install.sh
```
然后到`Profiles` -> `Profile Preferences`选择合适的xxx for powerline的字体即可。

## Powerline 4 BASH
&emsp;安装好powerline后，就是配置`.bashrc`了。
```
$ cat >> .bashrc << EOF
source $(pip show powerline-status | awk '/Location:/{print $2 "/powerline/bindings/bash/powerline.sh"}')
EOF
```

## Powerline 4 VIM
&emsp;相对BASH，将Powerline配置到VIM会复杂一些。首先要准备一个支持Python2的VIM，具体操作请参考[《让VIM支持Python2 by update-alternatives》](http://www.cnblogs.com/fsjohnhuang/p/6056651.html)。然后
```
$ cat >> .vimrc << EOF
set rtp+=$(pip show powerline-status | awk '/Location:/{print $2 "/powerline/bindings/vim"}')

" These lines setup the environment to show graphics and colors correctly.
set nocompatible
set t_Co=256
 
let g:minBufExplForceSyntaxEnable = 1
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
 
if ! has('gui_running')
   set ttimeoutlen=10
   augroup FastEscape
      autocmd!
      au InsertEnter * set timeoutlen=0
      au InsertLeave * set timeoutlen=1000
   augroup END
endif
 
set laststatus=2 " Always display the statusline in all windows
set guifont=Inconsolata\ for\ Powerline:h14
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
EOF
```

## 总结
最终效果图：
![](./powerline.png)
&emsp;尊重原创，转载请注明来自：^_^肥仔John
## 感谢
[为Bash和VIM配置一个美观奢华的状态提示栏](http://cenalulu.github.io/linux/mac-powerline/)
