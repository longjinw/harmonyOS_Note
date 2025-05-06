import router from '@ohos.router';
import { initRdb } from '../pages/databaseManager'; // 导入数据库初始化方法

@Entry
@Component
struct Main {
  aboutToAppear() {
    // 初始化数据库
    initRdb(getContext(this));

    // 跳转到登录页面
    router.pushUrl({ url: 'pages/login' });
  }

  build() {
    Column() {
      Text('易记')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFA500') // 设置字体颜色为橙色（艺术字效果）
        .margin({ top: 100 })
        .onClick(() => {
          router.push({ url: 'pages/login' });
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5DEB3') // 设置整体底色为米黄色
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      router.push({ url: 'pages/login' });
    });
  }
}
