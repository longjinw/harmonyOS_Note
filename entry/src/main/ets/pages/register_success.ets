import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface RegisterParams {
  nickname: string;
  account: string;
}

@Entry
@Component
struct RegisterSuccess {
  @State nickname: string = '';
  @State account: string = '';

  aboutToAppear() {
    const params = router.getParams() as RegisterParams;
    if (params) {
      this.nickname = params.nickname;
      this.account = params.account;
    }
  }

  build() {
    Column() {
      // 成功图标
      Image($r('app.media.ic_gallery_material_select_checkbox'))
        .width(80)
        .height(80)
        .margin({ top: 100, bottom: 30 })
        .fillColor('#4CAF50')

      // 成功提示
      Text('注册成功！')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4A4A4A')
        .margin({ bottom: 40 })

      // 用户信息卡片
      Column() {
        Row() {
          Text('昵称：')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.nickname)
            .fontSize(16)
            .fontColor('#333333')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 16 })

        Row() {
          Text('账号：')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.account)
            .fontSize(16)
            .fontColor('#333333')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 40 })

      // 返回登录按钮
      Button('返回登录')
        .width('85%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#E6D5B8')
        .borderRadius(25)
        .onClick(() => {
          router.push({ url: 'pages/login' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
  }
}