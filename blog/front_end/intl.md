# JS魔法堂:不完全国际化&本地化手册

## 前言
&emsp;最近加入到新项目组负责前端技术预研和选型，其中涉及到一个熟悉又陌生的需求——国际化＆本地化。熟悉的是之前的项目也玩过，陌生的是之前的实现仅仅停留在"有"的阶段而已。趁着这个机会好好学习整理一下，为后面的技术选型做准备。

## 何为国际化？
&emsp;国际化我认为就是应用支持多语言和文化习俗(数字、货币、日期和字符比较算法等)，而本地化则是应用能识别用户所属文化习俗自动适配至相应的语言文化版本。
&emsp;过去常常以为国际化就是字符串的替换——如"你好!"替换为"What's up, man!"，其实具体是分为以下5方面:
1. 字符串替换
&emsp;如`"你好!"`替换为`"What's up, man!"`.
2. 数字表示方式
&emsp;如`1200.01`，英语表示方式为`1,200.01`，而法语则为`1 200,01`，德语则为`1.200,01`.
3. 货币表示方式
&emsp;如人民币`￥1,200.01`，美元表示方式为`$1,200.01`，而英语的欧元则为`€1,200.01`，德语的欧元则为`1.200,01 €`.
注意: 这里没有还没算上汇率呢.
4. 日期表示方式
&emsp;如`2016年9月15日`，英语表示方式为`9/15/2016`, 而法语为`15/9/2016`, 德语为`15.9.2016`.
5. 字符比较算法
&emsp;如`ä`和`z`比较时，英语、德语中均是`ä`排在`z`前面，而在瑞典语中则是`z`排在`ä`前面.

## 本地化的关键 —— Language Tag
&emsp;既然要自动适配至用户所属的语言文化版本，那么总得有个根据才能识别吧？我想大家应该对`zh-CN`和`en`等不陌生吧，而它们正是我们所需的根据了！在我们使用已有i18n库实现国际化/本地化时，必定会写下以下文档
```
{
  "en": { "name": "Enter Name" },
  "zh-CN": { "name": "输入姓名" }
}
```
&emsp;但除了`en`和`zh-CN`还有其他键吗？它们的组成规则又是如何的呢？下面我们来稍微深入的了解这些Language Tag吧！

### 语法规则
注意以下采用ABNF语言描述(ABNF的语法请参考[语法规范：BNF与ABNF](http://kb.cnblogs.com/page/189566/))
```
Language-Tag = langtag
             / privateuse
             / grandfathered

langtag = language
          ["-" script]
          ["-" region]
          *("-" variant)
          *("-" extension)
          ["-" privateuse]
```
可以看到`Language-Tag`分为`langtag`，`privateuse` 和 `grandfatherd`三个子类,下面我们先了解一般情况用不上的两个吧！
**privateuse**
&emsp;标签的意思不由subtag registry定义，而是由使用的团队间私自定义、维护和使用。
&emsp;格式:
```
privateuse = "x" 1*("-" (1*8alphanum))
```
示例:`x-zh-CN`是privateuse，其意思不一定与language`zh-CN`一致。
注意: 只作为小集团内部用可以，决不能大范围适用。

**grandfathered**
&emsp;用于向后兼容。由于RFC 4646前的标签无法完全匹配当前registry的标签语法和意思，因此通过grandfathered来提供向后兼容的特性。
&emsp;语法:
```
grandfathered = irregular
              / regualr
irregular = "en-GB-oed"         ; irregular tags do not match
          / "i-ami"             ; the 'langtag' production and
          / "i-bnn"             ; would not otherwise be
          / "i-default"         ; considered 'well-formed'
          / "i-enochian"        ; These tags are all valid,
          / "i-hak"             ; but most are deprecated
          / "i-klingon"         ; in favor of more modern
          / "i-lux"             ; subtags or subtag
          / "i-mingo"  
          / "i-navajo"
          / "i-pwn"
          / "i-tao"
          / "i-tay"
          / "i-tsu"
          / "sgn-BE-FR"
          / "sgn-BE-NL"
          / "sgn-CH-DE"
regular = "art-lojban"        ; these tags match the 'langtag'
        / "cel-gaulish"       ; production, but their subtags
        / "no-bok"            ; are not extended language
        / "no-nyn"            ; or variant subtags: their meaning
        / "zh-guoyu"          ; is defined by their registration
        / "zh-hakka"          ; and all of these are deprecated
        / "zh-min"            ; in favor of a more modern
        / "zh-min-nan"        ; subtag or sequence of subtags
        / "zh-xiang"
```
注意: 几乎所有grandfarthered标签均可被当前registry的标签及其组合作替代(像`i-tao`可以被`tao`代替)，因此如无意外请使用现行的标签吧。

下面就到了我们的重头戏langtag了,首先我们看看langtag下的第一个subtag——language.
#### Primary language subtag
&emsp;像`en`这种就是Primary language subtag，用于标识资源所对应的语言。
&emsp;语法:
```
language = 2*3ALPAH
           ["-" extlang]
         / 4ALPHA
         / 5*8ALPHA
extlang = 3ALPHA
          *2("-" 3ALPHA)
```
看到language有三种形式，其中让我比较好奇的是第一种`2*3ALPHA ["-" extlang]`。这种形式中前面的`2*3ALPHA`称为macrolanguage，用于标明资源对应一种语言的汇总，而具体的某一种语言/方言则通过extlang指定。而包含extlang部分的language也被称为encompassed language.
如`zh-cmn`和`zh-yue`就是encompassed language，其中`zh`是macrolanguage，而`cmn`和`yue`则是extlang。
&emsp;这里有个很有趣的事情是，我们认为普通话和广东话等都是汉语的方言，但西方却认为普通话、广东话根本就不属于一种语言，因此像`zh-cmn`和`zh-yue`在规范中被设置为redundant，建议直接使用`cmn`和`yue`等。不过由于历史原因，我们还是使用`zh-CN`代表`cmn-CN`。
&emsp;另外现在可以作为macrolanguage的就只有7个标签(`ar`,`kok`,`ms`,`sw`,`uz`,`zh`和`sgn`)
&emsp;另外几个和cmn类似的subtags如下
```
cmn 普通话（官话、国语）
wuu 吴语（江浙话、上海话）
czh 徽语（徽州话、严州话、吴语-徽严片）
hak 客家语
yue 粤语（广东话）
nan 闽南语（福建话、台语）
cpx 莆仙话（莆田话、兴化语）
cdo 闽东语
mnp 闽北语
zco 闽中语
gan 赣语（江西话）
hsn 湘语（湖南话）
cjy 晋语（山西话、陕北话）
```
注意: 一般采用全小写
#### Script subtag
&emsp;用于指定字迹或文字系统资源所属的语言和方言等。
&emsp;语法:
```
script = 4ALPHA
```
注意: 一般采用首字母大写，后续字母全小写
#### Region subtag
&emsp;指定与国家、地域对应的语言/方言文化。
&emsp;语法:
```
region = 2ALPHA
       / 3DIGIT
```
注意: 一般采用全大写
#### Variant subtag
&emsp;指定其他subtag又无法提供的额外信息
&emsp;语法:
```
variant = 5*8alphanum
        / (DIGIT 3alphanum)
```
示例:`de-CH-1996`其中1996是variant subtag，整体意思是在Switzerland使用的自1996改良过的德语。
#### Extension subtag
&emsp;提供一种机制让我们去扩展langtag
&emsp;语法:
```
extension = singleton 1*("-" (2*8alphanum))
singleton = DIGIT
          / %x41-57
          / %x59-5A
          / %x61-77
          / %x79-7A
```
现在仅支持`u`作为sigleton的值。
示例:`de-DE-u-co-phonebk`表示采用电话本核对的方式对内容进行排序等操作。

更多关于language-tag的信息请参考[BCP 47](http://www.rfc-editor.org/rfc/bcp/bcp47.txt)

### 如何选择Language Tag
&emsp;硬着头皮啃下这么多规范的内容，但我还不知道如何组合合适的language-tag呢:(。其实选择和组合的原则就只有一条
**在足以区别当前上下文中其他language-tag的前提下，保持language-tag足够地短小精干**
示例1:下文普通话、粤语并存
```
<p lang="cmn">
小陈说:"老大爷，东方广场怎么走啊？"
老大爷回答道:"<span lang="yue">你讲咩也啊？我听唔明喔。</span>"
</p>
```
示例2:下文含大陆人讲英语、香港人讲普通话和美国人说英语
```
<p lang="cmn">
小陈说:"<span lang="en-CN">Hi, where are you come from?</span>"
李先生说:"<span lang="cmn-HK">你的英文跟我的普通话一样普通啊，哈哈！</span>"
Simon说:"<span lang="en">Hey, what's up!</span>"
</p>
```
&emsp;那现在引出另一个问题，那就是我们怎么知道各个subtag具体定义了哪些值呢？
具体都定义在[IANA Language Subtag Registry](http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)中了。
假如觉得查找起来还是不方便，那么就使用[Language Subtag Lookup tool](http://r12a.github.io/apps/subtags/)吧！
另外若不清楚各国各地区所使用的语言或方言时，可通过[Ethnologue](http://www.ethnologue.com/)查看，直接点击地图上的区域即可获取相应的subtag信息。
 
## 认识JavaScript Internationalization API
&emsp;有了本地化识别的根据(language tag)后，我们就可以开始实现本地化处理了，但从头开始处理还累了，幸好H5为我们提供新的API来减轻我们的工作量。它们分别是处理排序的`Intl.Collator`,处理日期格式化的`Intl.DateTimeFormat`和处理数字/货币等格式化的`Intl.NumberFormat`。
### Intl.Collator
&emsp;用于字符排序.
```
new Intl.Collator([locales[, options]])
@param Array|String [locales] - language-tag字符串或数组
@param Array        [options] - 配置项
```
options的属性及属性值(如无特别说明则values第一个值为默认值)
```
@prop String localeMatcher
@desc   指定用于locale匹配的算法
@values 'best fit' | 'lookup'

@prop String usage
@desc   指定用途
@values 'sort' | 'search'

@prop String sensitivity
@desc   指定对比时是否忽略大小写、读音符号
@values 'base'    - 大小写不敏感,读音符号不敏感
        'accent'  - 除采用base规则外，读音符号敏感
        'case'    - 除采用base规则外，大小写敏感
        'variant' - base,accent和case的并集 

@prop Boolean ignorePunctuation
@desc   指定是否忽略标点符号
@values false | true

@prop Boolean numeric
@desc   指定是否将两个数字字符转换为数字类型再作比较
@values false | true

@prop String caseFirst 
@desc   指定是否以大写或小写作优先排序
@values 'false' | 'upper' | 'lower' 
```
实例方法
```
Intl.Collator.prototype.compare(a, b):Number
@desc 比较字符串a和字符串b，若a排在b前面则返回-1，等于则返回0，排在后面则返回1.

Intl.Collator.prototype.resolveOptions():Object
@desc 返回根据构造函数中options入参生成的最终采用的options
```

### Intl.DateTimeFormat
&emsp;用于日期格式化输出.
```
new Intl.DateTimeFormat([locales[, options]])
@param Array|String [locales] - language-tag字符串或数组
@param Array        [options] - 配置项
```
options的属性及属性值(如无特别说明则values第一个值为默认值)
```
@prop String localeMatcher
@desc   指定用于locale匹配的算法
@values 'best fit' | 'lookup'

@prop String timeZone 
@desc   指定被格式化的时间所在的时区
@values [IANA time zone database](https://www.ia    na.org/time-zones) such as "Asia/Shanghai", "Asia/Kolkata", "America    /New_York", "UTC"

@prop String timeZoneName
@desc   指定格式化后所显示的时区样式
@values 'short' | 'long'

@prop Boolean hour12
@desc   指定采用12小时制还是24小时制 
@values false | true
@default-value 由locales入参决定

@prop String year 
@desc 指定年份的样式
@values 'numeric' | '2-digit' | 'narrow' | 'short' | 'long'

@prop String month
@desc 指定月份的样式
@values 'numeric' | '2-digit' | 'narrow' | 'short' | 'long'

@prop String day
@desc 指定日期的样式
@values 'numeric' | '2-digit'

@prop String hour 
@desc 指定小时的样式
@values undefined | 'numeric' | '2-digit'

@prop String minute
@desc 指定分钟的样式
@values undefined | 'numeric' | '2-digit'

@prop String second
@desc 指定秒的样式
@values undefined | 'numeric' | '2-digit'

@prop String weekday
@desc 指定周的样式
@values 'narrow' | 'short' | 'long'
```
实例方法
```
Intl.Collator.prototype.format(a):String
@desc 格式化日期

Intl.DateTimeFormat.prototype.resolveOptions():Object
@desc 返回根据构造函数中options入参生成的最终采用的options
```

### Intl.NumberFormat
&emsp;用于数字、货币格式化输出.
```
new Intl.NumberFormat([locales[, options]])
@param Array|String [locales] - language-tag字符串或数组
@param Array        [options] - 配置项
```
options的属性及属性值(如无特别说明则values第一个值为默认值)
```
@prop String localeMatcher
@desc   指定用于locale匹配的算法
@values 'best fit' | 'lookup'

@prop String style
@desc   指定格式化的风格
@values 'decimal' | 'currency' | 'percent'
@remark 当style设置为currency后，属性currency必须设置

@prop String currency
@desc   指定货币的格式化信息
@values 如"USD"表示美元, "EUR"表示欧元, "CNY"表示RMB.[Current currency & funds code first](http://www.currency-iso.org/en/home/tables/table-a1.html)

@prop String currencyDisplay
@desc   指定货币符号的样式
@values 'symbol' | 'code' | 'name'

@prop Boolean useGrouping
@desc   指定是否采用如千位分隔符对数字进行分组
@values false | true

@prop Number minimumIntegerDigits
@desc   指定整数最小位数
@values 1-21

@prop Number maximumFractionDigits
@desc   指定小数部分最大位数
@values 0-20

@prop Number minimumFractionDigits
@desc   指定小数部分最小位数
@values 0-20

@prop Number maximumSignificantDigits
@desc   指定有效位最大位数
@values 1-21

@prop Number minimumSignificantDigits
@desc   指定有效为最小位数
@values 1-21
```
注意：minimumIntegerDigits,maximumFractionDigits和minimumFractionDigits为一组，而maximumSignificantDigits和minimumSignificantDigits为另一组，当设置maximumSignificantDigits后，minimumIntegerDigits这组的设置为全部失效。

上述Intl接口并不是所有浏览器均支持，幸好有大牛已为了我们准备好polyfill了，但由于Intl.Collator所以来的规则和实现的代码量较庞大，因此polyfill中仅仅实现了Intl.DateTimeFormat和Intl.NumberFormat接口而已，不过对于一般项目而言应该足矣。[Intl polyfill](https://github.com/andyearnshaw/Intl.js)

## 自己撸个i18n库玩玩
&emsp;现在我们可以动手撸个基本不能用的i18n库玩玩了:)但在动手之前我们来看看如何获取language-tag吧。
### 两种获取/设置language-tag的方式
1. 获取浏览器的language-tag
&emsp;一般来说浏览器语言的版本标示着用户所属或所期待接收哪种语言文化风俗的内容，于是通过以下函数获取浏览器的语言信息即可获取language-tag
```
function getLang(){
  return navigator.language || navigator.browserLanguage
}
```
2. 用户自定义language-tag
&emsp;大家在浏览苹果官网时也会发现以下界面，让我们自行选择language-tag。

&emsp;最适当的设置和获取language-tag的方式当然就是上述两种方式相结合啦！

## [Format.js](http://formatjs.io/)——用在生产环境的i18n库
&emsp;说了这么多那我们怎么让项目实现国际化/本地化呢？那当然要找个可靠的第三方库啦——Format.js，它不仅提供字符串替换还提供日期、数字和货币格式化输出的功能，而且各大前端框架都已将其作二次封装，使用得心应手呢！
要注意的是它依赖Intl.NumberFormat和Intl.DateTimeFormat，因此当浏览器部支持时需要polyfill一下。
```
var areIntlLocalesSupported = require('intl-locales-supported');

var localesMyAppSupports = [
    /* list locales here */
];

if (global.Intl) {
    // Determine if the built-in `Intl` has the locale data we need.
    if (!areIntlLocalesSupported(localesMyAppSupports)) {
        // `Intl` exists, but it doesn't have the data we need, so load the
        // polyfill and replace the constructors with need with the polyfill's.
        var IntlPolyfill = require('intl');
        Intl.NumberFormat   = IntlPolyfill.NumberFormat;
        Intl.DateTimeFormat = IntlPolyfill.DateTimeFormat;
    }
} else {
    // No `Intl`, so use and load the polyfill.
    global.Intl = require('intl');
}
```
原生JavaScript使用示例:
```
<div id="msg"></div>
<script>
  const msgs = {en: {GREETING: 'Hello {name}'}
               ,fr: {GREETING: 'Bonjour {name}'}}  
  const locale = getLang()
  const msg = (msgs[locale] || msgs.en).GREETING
  const txt = new IntlMessageFormat(msg, locale)
  document.getElementById('msg').textContent = txt.format({name: 'fsjohnhuang'})
</script>
```
Polymer组件使用示例:
```
<link rel="import" href="./bower_components/app-localize-behavior/app-localize-behavior.html">
<dom-module id="x-demo">
  <template>
    <div>{{localize('name')}}</div>
  </template>
  <script>
    Polymer({
      is: 'x-demo',
      properties: {name: {type: String, value: 'fsjohnhuang'}},
      behaviors: [Polymer.AppLocalizeBehavior],
      attached: function(){
        this.loadResources(this.resolveUrl('./locales.json'))
      }
    })
  </script>
</dom-module>
```
locales.json
```
{"en": {"GREETING": "Hello {name}"}
,"fr": {"GREETING": "Bonjour {name}"}}
```
更多的玩法请参考官网吧！

## Hold on!不仅仅是上述这些啦！
### 内容协商(Content Negotiation)
&emsp;记得第一次接触国际化和本地化时是指服务端根据language-tag向用户返回不用的内容，这其实是利用HTTP提供的Content Negotiation机制。其实就是通过`Accept`,`Accept-Language`和`Accept-Encoding`等请求头字段作为依据对存在多个可用展现方式的某一资源选择最优的展现方式返回给用户，如语言文化、适合在屏幕上浏览还是用于打印等。
&emsp;这里又分为服务端协商(Server-driven Negotiation)和代理端协商(Agent-driven Negotiation)
1. Server-driven Negotiation
&emsp;就是择优返回展现方式的算法由服务端提供的Content Negotiation就是Server-driven Negotiation了。
&emsp;一般通过`Accept`,`Accept-Language`,`Accept-Encoding`和`User-Agent`等请求头字段作为依据去选择最优解。
缺点:
 a. 服务端永远无法精准地计算出最优解，部分原因是因为内容如何展现是由代理端决定，而请求中无法获取代理端的所有信息，若允许获取代理端的所有信息，那么网络传送的数据量将变大而且会涉及隐私安全的问题;
 b. 服务端实现复杂度提高;
 c. 由于对于同一个url可能会返回不同的响应报文，因此不能利用公用的缓存去暂存响应报文，从而丧失进一步的优化空间。
2. Agent-driven Negotiation
&emsp;就是代理端从服务端接收到一个基本的响应后，然后择优展现方式的算法由代理端提供的Content Negotiation就是Server-driven Negotiation了。
&emsp;注意这里是先从服务端接收一个基本的响应，然后代理根据这个响应再计算最优的展现方式。那么这个基本的响应是什么呢？HTTP/1.1定义300(Multiple Choices)和406(Not Acceptable)两个HTTP status code来通知代理端，这个请求的采用Agent-driven negotiation.
缺点:
 a. 经过代理端计算后，需要发起第二个请求来获取最优展现形式的具体内容,响应延迟提高。
&emsp;综合上述两种方式得到一种称为透明协商(Transparent Negotiation)的方式，其实就是对缓存系统作修改，让其除URL外还可以识别其他请求头字段等信息，来映射特定展现方式的响应报文。也就是说择优算法部分还是由服务端提供。

这里看来国际化/本地化是Content Negotiation的子集哦！

300 Multiple Choices
&emsp;当请求的资源在多个位置找到时，这些位置将以列表的形式作为响应报文返回给用户，由用户自行选择具体要访问哪个位置。若服务端打算推荐某个位置作为优先选择时，可将该位置作为响应头字段`Location`的值返回.

406 Not Acceptable
&emsp;当服务端发现无法满足请求头的`Accept`,`Accept-Charset`,`Accept-Encoding`或`Accept-Language`时，则会返回406状态编码。

### `lang`属性也是国际化啦~~
### 样式也玩国际化
[Selectors Level 4](http://link.zhihu.com/?target=http%3A//dev.w3.org/csswg/selectors/%23lang-pseudo)已经加入对BCP 47高级匹配算法的支持，即有以下玩法
```
<style>
:lang(en){ color: red; }
div:lang(en-GB){ color: blue; }
</style>
<p>En janvier, toutes les boutiques de Londres affichent des panneaux 
<span lang="en-GB">SALE</span>, mais en fait ces magasins sont bien propres!</p>
<div lang="en-GB">BIG SALE</div>
```
还有
```
<style>
:lang(*-CH){color: red}
</style>
<p lang="de-CH">Hi guy!</p>
<p lang="it-CH">Hi man!</p>
```

## 坑
1. 以母语(中文)作为多语言的键
"一"对应的英语可能是`One`或`Monday`

2. 必须预定义多语言键
```
(i18n/setup
  {:zh {:CN {:monday "星期一"
             :monday_simple "周一"
             :order_not_exist "单号{no}不存在!"}}
   :en {:US {:monday "Monday"
             :monday_simple "M"
             :order_not_exist "There is no order {no}!"}}})

;;(i18n/set :locale "zh_CN")
(i18n/set :locale "")

(def m [:monday])
(def n [:order_not_exist :no "123"])
(i18n/format :monday_simple)
(i18n/format m)
(i18n/format n)
```


## 总结
  尊重原创，转载请注明来自:　^_^肥仔John
## 感谢
[网页头部的声明应该是用 lang="zh" 还是 lang="zh-cn"？](http://www.zhihu.com/question/20797118)
[Language Subtag Registry](http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)
[BCP 47](http://www.rfc-editor.org/rfc/bcp/bcp47.txt)
[Language on the Web](https://www.w3.org/International/getting-started/language)
[Choosing a Language Tag](https://www.w3.org/International/questions/qa-choosing-language-tags)
[Language tags in HTML and XML](https://www.w3.org/International/articles/language-tags/)
[Content Negotiation](https://www.w3.org/Protocols/rfc2616/rfc2616-sec12.html)


## 最差实践
intl-messageformat-with-locales.min.js

