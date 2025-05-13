import router from '@ohos.router';
import { User } from '../my_class/user';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SignIn {
  @State nickname: string = '';
  @State account: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.ic_public_arrow_left_filled'))
            .width(24)
            .height(24)
        }
        .backgroundColor('#F5F5DC')
        .onClick(() => {
          router.back();
        })

        Text('注册新账号')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4A4A4A')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 表单区域
      Column() {
        // 昵称输入框
        TextInput({ placeholder: '请输入昵称', text: this.nickname })
          .width('85%')
          .height(50)
          .backgroundColor('#FFFFFF')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .margin({ top: 30, bottom: 20 })
          .onChange((value: string) => {
            this.nickname = value;
          })

        // 账号输入框
        TextInput({ placeholder: '请输入账号', text: this.account })
          .width('85%')
          .height(50)
          .backgroundColor('#FFFFFF')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .margin({ bottom: 20 })
          .onChange((value: string) => {
            this.account = value;
          })

        // 密码输入框
        TextInput({ placeholder: '请输入密码', text: this.password })
          .width('85%')
          .height(50)
          .backgroundColor('#FFFFFF')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .type(InputType.Password)
          .margin({ bottom: 20 })
          .onChange((value: string) => {
            this.password = value;
          })

        // 确认密码输入框
        TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
          .width('85%')
          .height(50)
          .backgroundColor('#FFFFFF')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .type(InputType.Password)
          .margin({ bottom: 40 })
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        // 注册按钮
        Button('注册')
          .width('85%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#E6D5B8')
          .borderRadius(25)
          .onClick(async () => {
            await this.handleRegister();
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private async handleRegister() {
    if (!this.nickname || !this.account || !this.password || !this.confirmPassword) {
      promptAction.showToast({
        message: '请填写完整信息',
        duration: 2000
      });
      return;
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({
        message: '两次输入的密码不一致',
        duration: 2000
      });
      return;
    }

    try {
      const existingUser = await User.fetchFromDatabase(this.account);
      if (existingUser) {
        promptAction.showToast({
          message: '该账号已被注册',
          duration: 2000
        });
        return;
      }

      const currentTime = new Date();
      const newUser = new User(
        this.nickname,
        this.account,
        this.password,
        currentTime,
        currentTime,
        [currentTime]
      );

      await newUser.saveToDatabase();

      router.push({
        url: 'pages/register_success',
        params: {
          nickname: this.nickname,
          account: this.account
        }
      });
    } catch (error) {
      console.error('注册失败:', error);
      promptAction.showToast({
        message: '注册失败，请稍后重试',
        duration: 2000
      });
    }
  }
}
