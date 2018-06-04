CSS Reset:
**Normalize.css**
bootstrap已经集成了
安装: `bower install normalize.css --save`
使用: `<link rel="stylesheet" href="./bower_components/normalize-css/normalize.css">`
[对使用CSS Reset与否的讨论](https://www.zhihu.com/question/23554164)

取色器
`sudo apt install gcolor2`
配色工具kuler

动画库(http://visionmedia.github.io/move.js/)
move.js: `cnpm i move-js --save`

小图标库
http://www.iconfont.cn/plus

html
**Pug**
安装: `npm install gulp-pug`
初始化:
```
cat >> gulpfile.js <<eof
var pug = require('gulp-pug')
gulp.task('views', function(){
  return gulp.src('src/views/*.pug')
             .pipe(pug())
             .dest('dist/views/')
})
eof
```
vim-pug插件
```
Plugin 'git://github.com/digitaltoad/vim-pug.git'
```


任务管理器
**Gulp**
安装: `npm install gulp --save-dev`
初始化: 
```
cat > gulpfile.js <<eof
var gulp = require('gulp')
var combiner = require('stream-combiner2')

gulp.task('default', function(){
  // TODO
})
eof
```
stream-combiner2, 合并stream作异常处理

开发用http server - lite-server
安装: `cnpm i lite-server browser-sync connect-logger moment --save-dev`
package.json配置
```
"script": {
  "dev": "lite-server"
}
```
html格式美化`cnpm i gulp-html-prettiy --save-dev`
ES6编译器`cnpm i google-closure-compiler-js --save-dev`
polyfill($jscomp)[https://autobahn.s3.amazonaws.com/autobahnjs/latest/autobahn.min.jgz]

POSTCSS
安装: `cnpm i gulp-postcss gulp-sourcemaps autoprefixer postcss-cssnext debug --save-dev`
配置:
```
gulp.task('css', function () {
    var postcss    = require('gulp-postcss');
    var sourcemaps = require('gulp-sourcemaps');

    return gulp.src('src/**/*.css')
        .pipe(sourcemaps.init())
        .pipe(postcss([require('postcss-cssnext')]) )
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('build/'));
});
```


[BEM methodology](https://en.bem.info/)
`block`, 组件
`__element`, 组件的内部件
`--modifier`, 组件或部件状态
组合用法
`block__element`
`block--modifier`
`block__element--modifier`

ref
http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/



vi
模式: 
Normal Mode(默认模式)
Insert Mode, 可输入字符时的模式
Command/ex Mode, 窗口底部以`:`开头时的模式,其实就是vi的行编辑器
`:ex %`, 查看当前总行数和字符数
ex命令由**行地址/行号**和**命令**组成, 若行号缺省值为当前行`.`

行地址/行号
`.`, 当前行
`$`, 最后一行
`%`, 当前文档的每一行, 等同于`1,$`
`-`, 前一行, 组合`-2`,`.-`,`.-1`
`+`, 后一行, 组合`+2`,`.+`,`.+1`
`/pattern/`, 搜索匹配pattern的行, 组合`/pattern/+`, `/pattern/+2`, `/pattern1/,/pattern2/`

行范围
`<行地址/行号1>,<行地址/行号2>`, 表示从`行地址/行号1`到`行地址/行号2`
`<行地址/行号1>;<行地址/行号2>`，表示从`行地址/行号1`到`行地址/行号2`，并且将`行地址/行号1`作为当前行，因此`100;+1`既等于`100,101`

命令
`d`, 删除行
`m`, 移动行
`co`/`t`, 复制行
```
:1,12 d "删除1~12行
:1,12 m 100 "将1~12行移动到100行后
:1,12 co 100 "将1~12行复制粘贴到100行后
```
`#`, 显示行号和行内容
`:=`, 显示当前文件总行数
`:.=`, 显示当前行行号
`g/pattern/`，全局搜索, 补值`g!/pattern/`

组合命令
`:<ex command1> | <ex command2>`

复制内容到另一个文件
`w <filepath>`, 将某部分内容复制到新文件中
`w >> <filepath>`,将某部分内容追加到文件中

复制内容到当前文件`r`
将内容复制到命令行: 对内容进行yank，然后在命令行中`ctrl` + `r` `"`

搜索
`:,s/pattern//gc`
搜索模式
`magic`, 默认的搜索模式
`\v`, 

`/\v(any|number)` 等价于 `/\(any\|number\)`


1. 自动重载文件
将http://vim.wikia.com/wiki/Have_Vim_check_automatically_if_the_file_has_changed_externally的内容保存到`~/.vim/watchforchanges`,然后在.vimrc中添加`source ~/.vim/watchforchanges`
2. 自动设置当前编辑文件所在目录为工作目录`set autochdir`
3. shell交互
`:!<command>`, 执行执行shell　command后回车返回vim
`:<line number>[,<line number>]w !<command>`，以所选择的行作为standard input执行shell command，然后将standard output输出到vim 的命令窗口，然后按回车返回normal mode
示例
```
# 将当前行的内容作为shell command来执行
:.w !bash
```

`:<line number>[,<line number>] !<command>`以所选择的行作为standard input执行shell command，然后vim中所选的内容替换为standard output的内容
示例
```
# 对1到10行排序
:1,10 !sort
# 对当前行的小写字母替换为大写字母
:. !tr [a-z] [A-Z]
```
`:r !<command>`执行shell command，然后将standard output输出到vim光标的下一行
示例
```
:r !date
```
终极利器——`conque-shell`
http://www.vim.org/scripts/script.php?script_id=2771
下载conque_2.1.vba
安装: 
```
vim comque_2.1.vba
:so %
:q
```
使用
```
:ConqueTerm <command>
:ConqueTermSplit <command>
:ConqueTermVSplit <command>
:ConqueTermTab <command>
```
其中<command>可以为bash、python、mysql -h localhost -u joe -p sock_collection等。


Leader键, 用于作为自定义快捷键的激活键.
```
let mapleader = ","
```

插件管理器——Vundle
安装: `git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim `
.vimrc配置:
```
set nocompatiable
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 各种插件
call vundle#end()

filetype on
```
插件操作：
1. 安装:
在.vimrc中添加`Plugin '<插件名称/路径>'`, 然后执行如下命令
```
:so %
:PluginInstall
```
2. 清理闲置未用的插件
将.vimrc中的`Plugin '<插件名称/路径>'`删除，然后执行如下命令
```
:PluginClean
```

使用剪贴板
`set clipboard=unnamed`

使用相对行号
```
set nu
set rnu
```
缩进对后两行,在Normal mode中输入`>2j`
进入光标所在的文件,在Normal mode中输入`gf`
输入计算值，在Insert mode中输入`ctrl+r =1+2+3`
将光标所在的数字加20,在Normal mode中输入`20 ctrl+a`
搜索光标所在的词, 在Normal mode中输入`#`或`*`

Mark
查看已有的mark, `:marks`
创建文件内mark, 在Normal mode中输入`m<标记>`，其中标记取值为`{a-z}`
创建全局mark, 在Normal mode中输入`m<标记>`，其中标记取值为`{A-Z}`
跳转到mark所在行,在Normal mode中输入`'<标记>`
删除指定mark, `:delm<标记>`
删除所有mark, `:delm!`
插件
https://github.com/kshenoy/vim-signature

折叠
配置
```
set foldenable foldmethod=marker foldcolumn=1
```
foldmethod有6种方法
`manual`, 手工定义折叠
`indent`, 以缩进为选区来折叠
`expr`， 以表达式为选区折叠
`syntax`，以语法高亮定义折叠
`diff`, 对没有更改的文本进行折叠
`marker`, 标记选区进行折叠,用/*{{{{*/和/*}}}}*/标记选区
通用操作
```
zc 关闭当前打开的折叠
zo 打开当前的折叠
zm 关闭所有折叠
zM 关闭所有折叠及嵌套的折叠
zr 打开所有折叠
zR 打开所有折叠及嵌套的折叠
zd 删除当前折叠
zE 删除所有折叠
zj 移动到下一个折叠
zk 移动到上一个折叠
zn 禁用折叠
zN 启用折叠
[z 跳转到当前打开的折叠的开始处
]z 跳转到当前打开的折叠的末尾处
```
`:mkview`, 保存折叠信息
`:loadview`, 加载折叠信息
marker方式的操作
```
zf 创建折叠
zf% 创建从当前行起对应的匹配的括号((),{},[],<>等)
```

标签(tab-page)
帮助文档, `:help tab-page`
配置
```
" 配置可打开的标签页数
set tabpagemax=15
" 0:不显示标签栏;1:当标签数大于１时才显示标签栏;2:总显示标签栏
set showtabline=1
```
查看已打开的tab(>指向当前tab,+指向已修改过却未保存的tab),`:tabs`
关闭当前tab,`:tabc`
关闭其他tab,`:tabo`
创建tab,
打开多个独立tab的文件,`vim -p file1 ...`

Tmux
安装: `sudo apt install tmux`
配置文件`~/.tmux.conf`

前缀键<leader>: `Ctrl+b`
重新设置<leader>
```
unbind prefix C-b
set -g prefix C-a
```

Pane(窗格)
创建垂直窗格，`<leader> %`
创建水平窗格，`<leader> "`
窗格间移动, `<leader> 上/下/左/右`
关闭所有, `<leader> !`
关闭当前, `<leader> x`
翻页, `<leader> pageup/pagedown`
调整尺寸
```
<leader> <alt>+上/下/左/右
```

Window(窗口)
内含1~N个窗格
创建，`<leader> c`
重命名, `<leader> ,` , 防止自动重命名`set-option -g allow-rename off`
窗口间移动, `<leader> <窗口的数字>`
通过名字搜索，`<leader> f`
按顺序切换, `<leader> w`
切换到下一个, `<leader> n`
切换到上一个, `<leader> p`
切换到最后一个, `<leader> l`
关闭, `<leader> &`
暂时切断， `<leader> d`

Session(会话)
内含1~N个窗口
除非显示关闭，否则系统重启前即使退出tmux，它的会话都不会被关闭。

创建, `tmux new -s <new-session-name>`
在会话A中跳转到另一个会话, `<leader> : new -s <new-session-name>`
查看会话列表, `<leader> s`, `tmux ls`
附加到会话, `tmux attach`, `tmux attach-session -t <session-id>`

使用vim的键模式
`setw -g mode-keys vi`

选择复制
1. `<leader> [`,进入选择模式 
2. 按`空格键`,开始选择
3. 按`回车键`,选择结束
4. `<leader> ]`,粘贴刚才复制的内容

美化状态栏
```
# 状态栏
# 颜色
set -g status-bg black
set -g status-fg white

# 对齐方式
set-option -g status-justify centre

# 左下角
set-option -g status-left '#[bg=black,fg=green][#[fg=cyan]#S#[fg=green]]'
set-option -g status-left-length 20

# 窗口列表
setw -g automatic-rename on
set-window-option -g window-status-format '#[dim]#I:#[default]#W#[fg=grey,dim]'
set-window-option -g window-status-current-format '#[fg=cyan,bold]#I#[fg=blue]:#[fg=cyan]#W#[fg=dim]'

# 右下角
set -g status-right '#[fg=green][#[fg=cyan]%Y-%m-%d#[fg=green]]'

# 打开新的window或者分屏时，当前目录默认为新建window或者分屏前所处的目录
bind s split-window -h -c "#{pane_current_path}"
bind v split-window -v -c "#{pane_current_path}"
bind-key c  new-window -c "#{pane_current_path}"
```

Tmuxinator
```
sudo apt install gem
gem sources --add http://gems.ruby-china.org/ --remove https://rubygems.org/
sudo gem install tmuxinator
```
```
# 创建
tmuxinator new project_a
# 进入
tmuxinator start project_a
```

SQLPLUS
设置编码字符集
查看服务端编码字符集
```
SQL> select * from nls_database_parameters;
```
查看`NLS_LANGUAGE`和`NLS_TERRITORY`和`NLS_CHARACTERSET`三个值
然后在`.bashrc`或`.profile`中追加`export NLS_LANG=${NLS_LANGUAGE}_${NLS_TERRITORY}.${NLS_CHARACTERSET}`

Git
[沉浸式学 Git](http://igit.linuxtoy.org/contents.html)

Linux
https://linuxtoy.org/

产品页
电商首页

## Emmet.vim
1. Expand abbreviation
inputs `ul>li*3`, then presses `<c-y>` + `,`
```html
<!-- result -->
<ul>
	<li></li>
	<li></li>
	<li></li>
</ul>
```
2. Wrap with abbreviation
determins selections, presses `<c-y>` + `,`, then inputs abbrevation cluses and presses `enter`
3. 跳转到下一个编辑点`<c-y>` + `n`
4. 跳转到上一个编辑点`<c-y>` + `N`
5. 选中整个元素`<c-y>` + `d`
6. 选中元素的内容`<c-y>` + `D`
7. 合并行`<c-y>` + `m`
8. 移除标签对`<c-y>` + `k`
9. 合并/分割元素`<c-y>` + `j`
10.注释`<c-y>` + `/`
11.url生成锚`<c-y>`+`a`
``` config
# cat >> ~/.vimrc
let g:user_emmet_settings = {
\ 'php' : {
\ 'extends' : 'html',
\ 'filters' : 'c',
\ },
\ 'xml' : {
\ 'extends' : 'html',
\ },
\ 'haml' : {
\ 'extends' : 'html',
\ },
\}
let g:user_emmet_expandabbr_key = '<Tab>'
```


国内替换
http://fonts.googleapis.com/css?family=Source+Sans+Pro:300,300italic,400,600
为
http://www.googlefonts.cn/fonts?family=Source+Sans+Pro:300,300italic,400,600


