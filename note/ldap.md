LDAP(Lightweight Directory Access Protocol，轻量目录访问协议)是基于TCP/IP的应用层协议，默认端口为389，加密端口为636.

## 操作
1. 用户验证(bind操作)
2. 添加节点
3. 更新节点
4. 删除节点
5. 移动节点
6. 节点搜索

整个存储结构为树结构
节点就是存储数据的记录
节点含多个属性，可存储记录的业务数据和元数据
一个属性可含多个值
节点必须包含属性DN(Distinguished Name)来唯一标识
DN=RDN(Relative Distingushed Name)+父节点的DN

DN示例，从右到左为根节点->子节点：
```
dn:CN=John Doe,OU=Texas,DC=example,DC=com
```
其中DC为所在控制器，OU为组织单元，CN为通用名称

## 身份验证
```c#
// LDAP服务地址
String IP = "10.16.48.29";
// 基对象/节点DN
String BaseDN = "o=user,o=isp";
// 入口路径
String Path = new UriBuilder("ldap", IP, 389, BaseDN).ToString();
// 帐号，通过DN的方式定义
String Account = "uid=user_bind,ou=mygroup,o=isp";
// 密码
String Password = "test";
// 验证方式(方式多样)
// 0 - 基本身份验证(即简单绑定)
AuthenticationTypes AuthenticationType = AuthenticationTypes.None;

// 执行身份验证，成功则得到基对象/节点
DirectoryEntry Root = new DirectoryEntry(Path, Account, Password, AuthenticationType);

if (null == Root){
  Console.WriteLine("验证失败");
}

// 释放资源
if (null != Root){
  Root.Close();
}
```

## 节点搜索
```c#
// 以Root为基对象执行节点搜索操作
DirectorySearch ds = new DirectorySearch();
// 搜索的基对象
ds.SearchRoot = Root;
// 搜索字符串
ds.Filter = "(uid=123)";
// 搜索范围
// Base     - 搜索范围为基对象
// OneLevel - 搜索范围为基对象的直接子节点，不包含基对象
// Subtree  - 搜索限于基对象的子树，包含基对象
ds.SearchScope = SearchScope.Subtree;

// 多个值
SearchResultCollection Results = ds.FindAll();
// 单个值
SearchResult Result = ds.FindOne();

String propName = "cn";
SearchResultProperties properties = Result.Properties;
SearchPropertyValueCollection vals = Properties[propName];
foreach (var val in vals){
  Type typeOfVal = val.GetType();
  //.......
}
```
