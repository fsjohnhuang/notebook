# 打造高效前端工作环境 - tmux

## 前言

## tmux入门
### 安装,`sudo apt install tmux`
### tmux的C/S架构
服务端(Server), 1个服务端维护1～N个会话;
会话(Session), 1个会话对应1~N个窗口;
窗口(Window), 1个窗口对应1~N个窗格;
窗格(Pane)，vim、bash等具体任务就是在窗格中执行。

1.进入tmux
&emsp;在shell中执行`tmux`就会自动创建一个匿名会话、窗口和窗格，而窗格内正在运行着另一个shell程序，这时我们可以像平常使用shell一样来工作。而tmux真正的威力在于对会话、窗口和窗格的管理，但在此之前我们要先了解开启魔法的阀门——快捷键前缀(prefix)。

2.快捷键前缀(prefix)
&emsp;tmux为使自身的快捷键和其他软件的快捷键互不干扰，特意提供一个快捷键前缀,默认为`Ctrl`+`b`。因此当我们输入任何tmux快捷键前必须先输入`Ctrl`+`b`。
&emsp;由于快捷键前缀是可以重置的，因此后文将以`<prefix>`来指代快捷键前缀。

3.操作Pane
创建(通过分割当前pane实现)
`<prefix>` `"`,水平分割当前pane
`<prefix>` `%`,垂直分割当前pane
关闭
`<prefix>` `x`,删除当前pane
跳转
`<prefix>` `<up-arrow>`/`<down-arrow>`/`<left-arrow>`/`<right-arrow>`, 通过上下左右方向键跳转到对应的pane
`<prefix>` `;`,跳转到上次激活的pane
`<prefix>` `o`,跳转到下一个pane
`<prefix>` `q`,显示各pane的编号，并输入编号跳转到对应的pane
修改尺寸
`<prefix>`+`<up-arrow>`/`<down-arrow>`/`<left-arrow>`/`<right-arrow>`, 通过上下左右方向修改当前pane的高宽
缩放
`<prefix>` `z`,缩放当前pane
其他
`<prefix>` `{`,将当前pane移动到最左边
`<prefix>` `}`,将当前pane移动到最右边
`<prefix>` `!`,将当前pane转变成window

4.操作Windoiw
创建
`<prefix>` `c`,创建window
重命名
`<prefix>` `,`,重命名当前window
注意：由于tmux默认会根据当前pane执行的程序来改变window名称，因此需要在`~/.tmux.conf`中加入`set-option -g allow-rename off`来固化window名称。
关闭
`<prefix>` `&`,关闭当前window
跳转
`<prefix>` `n`,跳转到下一个window
`<prefix>` `p`,跳转到上一个window
`<prefix>` `0`...`9`,跳转到对应的window
其他
`<prefix>` `:swap-window -s 2 -t 1`, 调转编号为2和1的两个window的次序
5.操作Session
`<prefix>` `s`,显示所有会话
`<prefix>` `$`,重命名
`<prefix>` `d`,脱离当前会话
`<prefix>` `:kill-session`,关闭当前会话
`<prefix>` `(`,跳转到上一个会话
`<prefix>` `)`,跳转到下一个会话

## tmux进阶
1.细抠Session操作
&emsp;我们为前端开发环境和后端开发环境分别创建两个Session来独立管理，那么我们就可以灵活地在两个Session间穿梭，并且可以分别和前端、后端开发人员协同工作，下面我们看看相关的命令吧。
`$ tmux` 或 `<prefix>` `:new`, 创建匿名Session
`$ tmux new -s mysession` 或 `<prefix>` `:new -s mysession`, 创建名为mysession的Session
`$ tmux kill-session -t mysession`,关闭mysession会话
`$ tmux kill-session -a`,关闭所有会话
`$ tmux ls`,显示所有会话信息
`$ tmux a`,附加到最近一个会话
`$ tmux a -t mysession`,附加到会话mysession

2.多个panes输入同步
`<prefix>` + `:setw synchronize-panes`<br>
&emsp;这个功能在通过ssh维护多台服务器时十分有用！

3.复制粘贴
&emsp;通过tmux我们可以通过纯键盘操作实现跨pane的复制粘贴。首先在`~/.tmux.conf`文件中添加`setw -g mode-keys vi`，启用vi键盘方式(`hjkl`方向键,`/?nN`搜索)操作buffer内容。
进入复制模式,`<prefix>` `[`
开始选择,`<Spacebar>`
选择结束并将内容复制到新的buffer,`<Enter>`
取消选择,`<Esc>`
从buffer\_0粘贴到光标位置，`<prefix>` `]`
&emsp;可见复制的内容均暂存在buffer中，而tmux也提供直接操作buffer的命令给我们.
`<prefix>` `: show-buffer`，显示buffer\_0的内容
`<prefix>` `: capture-pane`, 保存当前pane的内容
`<prefix>` `: list-buffers`, 显示所有buffer内容
`<prefix>` `: choose-buffer`, 选择buffer并粘贴
`<prefix>` `: save-buffer buf.txt`, 保存buffer内容到but.txt
`<prefix>` `: delete-buffer -b 1`, 删除buffer\_1的内容

4.美化状态栏
&emsp;默认的tmux样式有点丑，而https://github.com/gpakosz/.tmux这个配置则为我们提供漂亮状态栏.
![](./tmux-powerline.png)

2.配置
```
# Send prefix
unbind C-b
set -g prefix C-a
```
```
setw -g mode-keys vi

# Send prefix
set-option -g prefix C-a
unbind-key C-a
bind-key C-a send-prefix

# Use Alt-arrow keys to switch panes
bind -n M-h select-pane -L
bind -n M-l select-pane -R
bind -n M-k select-pane -U
bind -n M-j select-pane -D

# Shift-arrow keys to switch window
bind -n S-h previous-window
bind -n S-l next-window

# Mouse mode
set -g mode-mouse on
set -g mouse-resize-pane on
set -g mouse-select-pane on
set -g mouse-select-window on

# Set easier window split keys
bind-key h split-window -h
bind-key v split-window -v

# Easy config reload
bind-key r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."
```


### 插件
#### 插件管理器——tpm
安装与配置
```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm &&
cat >> ~/.tmux.conf << eof
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
eof
```
```
$ tmux source ~/.tmux.conf
```
安装插件,`<prefix>` `I`
更新插件,`<prefix>` `U`
卸载插件,`<prefix>` `Alt`+`u`

### 资料
http://tmuxcheatsheet.com/

## Tmuxinator - 工作环境保存/恢复利器
Repos: [https://github.com/tmuxinator/tmuxinator](https://github.com/tmuxinator/tmuxinator)
### 安装与配置
&emsp;安装gem
```
$ sudo apt install gem
$ gem sources --remove https://rubygems.org --add http://gems.ruby-china.org/
```
&emsp;确保gem的源有且仅有http://gems.ruby-china.org/
```
$ gem sources -l
```
&emsp;安装Tmuxinator
```
$ gem install tmuxinator
```
&emsp;配置别名mux和tmuxinator子命令智能补全
自动根据使用的shell(bash,zsh,fish)下载配置脚本，并启用配置。
```
$ if [[ $SHELL == *fish* ]];then pushd ~/.config/fish/completions/; else pushd ~/.tmuxinator/; fi &&
curl -O "https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.$(basename $SHELL)" &&
popd &&
if [[ $SHELL != *fish* ]];then echo "source ~/.tmuxinator/tmuxinator.$(basename $SHELL)" >> ~/.$(basename $SHELL)rc; fi &&
if [ -z $EDITOR ];then echo "export EDITOR='vim'" >> ~/.$(basename $SHELL)rc; fi &&
source ~/.$(basename $SHELL)rc
```
### 入门
1.创建并编辑项目配置,`mux n <project_name>`
示例:
```
$ mux n demo
```
然后进入项目配置编辑界面
```
# ~/.tmuxinator/demo.yml
# 默认配置
name: demo #项目(配置)名称,不要包含句号
root: ~/   #项目的根目录，作为后续各命令的当前工作目录使用

windows:
	- editor: # 配置名称为editor的窗口
			layout: main-vertical # 由于editor下存在多个窗格，因此需要layout可以设置布局(5个默认值even-horizontal,even-vertical,main-horizontal,main-vertical,tiled)
			panes:
				- vim # 配置一个窗格运行vim
				- guard # 配置另一个窗格运行guard
	- server: bundle exec rails s # 配置名称为server的窗口, 且仅有一个执行bundle exec rail s的窗格
	- logs: tail -f log/development.log # 配置名称为logs的窗口, 且仅有一个执行tail -f log/development.lgo的窗格
```
根据修改配置得到如下
```
# ~/.tmuxinator/demo.yml
name: demo
root: ~/repos/demo/

windows:
	- editor: vim index.html
	- server: npm run dev
	- stats:
			layout: even-horizontal
			panes:
				- npm run html
				- npm run css
				- npm run js
	- note:
			root: ~/repos/note/ # 可在窗口下通过root来配置该窗口下各命令的当前工作目录
			panes:
				- vim pugjs.md
```
然后保存文件就OK了！

2.打开项目(i.e.根据项目配置启动tmux会话),`mux <project_name>`或`mux s <project_name>`
示例:
```
$ mux demo
```
然后tmuxinator就会创建一个tmux会话,并根据刚才编辑的配置文件创建窗口和窗格

3.关闭项目(i.e.根据项目配置关闭tmux会话),`mux st <project_name>`
示例:在tmux某个shell中输入
```
$ mux st demo
```

4.编辑项目配置,`mux e <project_name>` 或 `mux o <project_name>`
5.查看现有项目配置,`mux l`
6.删除项目(i.e.删除现有项目配置),`mux d <project_name> [<project_name>]*`
7.修改项目配置名称,`mux c <old_project_name> <new_project_name>`

### 进阶
1.项目配置文件路径随心玩
&emsp;眼利的同学可能会发现当我们输入`mux n demo`后创建的配置文件首行为`# ~/.tmuxinator/demo.yml`，这个正是demo这个项目配置文件的路径。也就是说默认情况下项目配置将保存在`~/.tmuxinator/`下，并以`项目名称.yml`作为文件名。这样我们就能在任意目录下通过命令`mux <project_name>`打开项目了。
&emsp;但一旦误删了项目配置那么就要重新设置了，能不能把它也挪到项目中通过版本管理器(git etc.)作保障呢？必须可以的哦！
```
# 假设项目目录为~/repos/demo/
$ mv ~/.tmuxinator/demo.yml ~/repos/demo/.tmuxinator.yml &&
ln -s ~/repos/demo/.tmuxinator.yml ~/.tmuxinator/demo.yml
```
emsp;那么除了通过`mux <project_name>`外，当`pwd`为项目目录时，直接输入`mux`也会打开当前项目。而且可以通过`mux`的其他命令来管理项目配置文件。
emsp;当下次从版本管理器下载项目后，直接执行
```
$ ln -s ~/repos/demo/.tmuxinator.yml ~/.tmuxinator/demo.yml
```

2.引入变量到项目配置文件中
&emsp;参数形式
```
# ~/.tmuxinator/demo.yml
name: demo
root: ~/<%= @args[0] %>

.........
```
调用`mux demo args0 args1`
&emsp;键值对形式
```
# ~/.tmuxinator/demo.yml
name: demo
root: ~/<%= @settings["ws"] %>

.........
```
调用`mux demo ws="repos/demo/"`
&emsp;环境变量
```
# ~/.tmuxinator/demo.yml
name: demo
root: ~/<%= ENV["ws"] %>

.........
```
调用`set $ws="repos/demo/" && mux demo`

3.设置开发环境上下文
&emsp;在项目配置文件中加入`pre_window`配置项。
示例:
```
name: demo
root: ~/repos/demo
pre_window: nvm use 4
```
### 遗留问题
&emsp;大部分情况下多个窗格水平、垂直并存的布局方式，那tmuxinator的提供的5种布局选项明显无法满足我们的需求，虽然我们可以自定义布局，但感觉有点复杂，有没有工具可以自动生成项目配置文件呢？

## tmux-resurrect 和 tmux-continuum

## 感谢
http://www.tuicool.com/articles/QBfIJr
