本仓是一个完整项目

## 协议

本仓库遵循GNU General Public License V3（以下简称GPL）协议，GPL的出发点是代码的开源、免费使用和引用、修改/衍生代码的开源、免费使用，**但不允许使用修改后和衍生的代码做为闭源的商业软件发布和销售**。

## Pods

依赖的第三方库包括

`Classy` UI配置文件 

`DateTools` 相对时间计算工具 

`DZNEmptyDataSet` 空白tableview样式

`Fork-MWFeedParser` 我fork MWFeedParser的仓，修改了网络协议、解析协议、时间格式等内容

`IQKeyboardManager` 自动键盘收缩

`MagicalRecord` CoreData封装

`Masonry` autolayout简化工具

`MGJRouter` 蘑菇街团队的路由插件

`MMKV` 微信的高速缓存工具

`Fork-MWPhotoBrowser` 图片浏览器，因为原作者不更新了，为了用上最新的SDWebImage，这个是我修改过的库

`pop` Facebook的动画库

`ReactiveObjC` github团队的函数编程框架

`RegexKitLite` 正则表达式

`SDWebImage` 网络图片缓存

`SVProgressHUD` HUD控件

`YYKit` 一个大杂库，主要用到字符串相关内容

依赖的第一方库（我自己封装的）

`oc-base` 提供OC的几个Runtime功能扩展，主要用到取类属性数组。

`oc-date` 时间计算，农历，这个项目基本没用到

`oc-string` 字符串处理，另外给NSArray提供 filter，map等函数支持

`oc-util` 包含两个工具，`GCDQuene`多线程对象化，`MVCKeyValue`是对MMKV的封装

`ui-base` 比较杂，主要用到对ViewController的简化封装，对UIAlertController的封装

`ui-util` 提供一个UI简化测试模型`UUTest`

`mvc-base` 这个是整个项目的设计构架基础库，原本设想设计一个MVC标准模版，结果实际成型以后类似VIPER构架，更多关于这个库的内容，稍后会出文档。