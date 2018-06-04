
非优化模式(debug: true)
  文件不会打包和压缩，并且不会采用`.min`版本的文件

模式切换
1. {Boolean} BundleTable.EnableOptimizations，false为非优化模式，true为优化模式
2. Web.config下
```
<system.web>
  <compilation debug="true"/>
</system.web>
```

1. 注册服务
`Golbal.asax.cs`的`Application_Start`方法下添加
```
BundleConfig.RegisterBundles(BundleTable.Bundles);
```
2. 配置优化
在`App_Start\BundleConfig.cs`的RegisterBundles方法下

```
bundles.Add(new ScriptBundle("~"))
```

