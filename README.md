# VOIPDemo
The Way To Awake  A Background Or Killed App




## 背景

虽然我在项目里面没有遇到这个需求，但是遇到了这个面试题，一时竟然说不出个所以然。趁热打铁，这篇文章就是为了实现一下这个功能。

## 需求

收款到账语音提醒需要收款方在收到款后，播放一段TTS合成语音播报金额。APP在前台时可以通过模板消息将需要播报的金额带下来，再请求TTS数据并播放，APP在后台的时候就需要用到 [VoIP Push Notification](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html) 
来实现客户端在被唤醒之后将获得30s的后台运行时间，这段运行时间足以请求合成语音数据并播放。本篇文章就基本实现实现这一个功能，合成语音那块采用的是一个网络音频资源替代。

##  技术点

### 1.1 方案选择
最开始准备用Remote Push + Notification  Service Extension 实现这个功能，遇到了很多坑，后来就放弃了，改用VOIP方案，完美解决。

### 1.2 测试推送
注意VOIP和APNS 服务的推送不是一个东西来的，所以用APNS的测试方法是调试不了的。我这里是用服务端推送代码并修改配置信息。
> VOIP文件夹下面需要像图片这样放好需要的证书文件，测试证书和生产证书共用一个
> 开发环境地址：gateway.sandbox.push.apple.com:2195 
生产环境地址： gateway.push.apple.com:2195

![Alt](https://github.com/linshengqi/MarkdownPhotos/blob/master/blog/voipfolder.png?raw=true
)

![Alt](https://github.com/linshengqi/MarkdownPhotos/blob/master/blog/voip_php.png?raw=true
)

用终端命令行cd到我们的VoIP文件夹中，输入：`php php文件名.php`
就会执行`- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type;` 

## 写在最后

代码要运行起来后需要创建证书，修改php文件才能看到效果。
