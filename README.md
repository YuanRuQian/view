# 毕业设计 ： View, 一个基于 flutter 的图片分享社交 APP

![view](assets/view.png)

## 数据库选择

Firebase

理由：
- 对于 flutter 的支持好




其他思考：

这种图片分享的 app 
用户活动都是 读 > 写 的
可能用户看了很多 post 才会 like / comment

所以我觉得设计应该写的时候费劲，读的时候省劲

就是说 某个用户上传了图片 上传的内容应该被复制后推送到所有订阅的用户的 feed 流

相应的 大V的存储会耗更多的钱（当然他们给平台带来的钱也更多

但是我是做一个 demo 所以暂时不考虑大量数据的问题

然后 就会有一个用户修改了个人信息 / po 新照片 这个修改怎么去推送给订阅人的问题 (fan-out operation)

这段参考： [https://medium.com/@garyalexanderpiong/building-a-working-instagram-clone-using-flutter-and-firebase-1c9f9bb960ef](https://medium.com/@garyalexanderpiong/building-a-working-instagram-clone-using-flutter-and-firebase-1c9f9bb960ef)

## 最后呈现安卓端产品

因为某果开发者认证 99 刀 安卓的免费……

## 数据模型设计

### 用户

用户ID
用户名
头像图片的URL
邮箱
简介

```
  final String id;
  final String name;
  final String profileImageUrl;
  final String email;
  final String bio;
```

测试账号：
email :  admin@view.com
password : 123456
