import router from '@ohos.router';

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
    Column({ space: 20 }) {
      Text('注册成功！')
        .fontSize(20)
        .fontWeight(FontWeight.Bold);

      Text(`昵称: ${this.nickname}`)
        .fontSize(16);

      Text(`账号: ${this.account}`)
        .fontSize(16);

      Button('返回登录页')
        .width('100%')
        .onClick(() => {
          router.push({ url: 'pages/login' });
        });
    }
    .height('100%')
    .width('100%')
    .padding(20);
  }
}