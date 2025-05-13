import router from '@ohos.router';
import { User } from '../my_class/user';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State rememberPassword: boolean = false;
  private preferences: preferences.Preferences | null = null;

  aboutToAppear() {
    this.initPreferences();
  }

  private async initPreferences() {
    const context = getContext(this) as common.UIAbilityContext;
    try {
      const pref = await preferences.getPreferences(context, 'login_info');
      this.preferences = pref;
      
      if (this.preferences) {
        const remember = await this.preferences.get('rememberPassword', false);
        this.rememberPassword = Boolean(remember);
        
        if (this.rememberPassword) {
          const savedAccount = await this.preferences.get('savedAccount', '');
          const savedPassword = await this.preferences.get('savedPassword', '');
          this.account = String(savedAccount);
          this.password = String(savedPassword);
        } else {
          // 如果不记住密码，清空输入框
          this.account = '';
          this.password = '';
        }
      }
    } catch (error) {
      console.error('初始化Preferences失败:', error);
    }
  }

  private async handleLogin() {
    if (!this.account || !this.password) {
      promptAction.showToast({
        message: '请输入账号和密码',
        duration: 2000
      });
      return;
    }

    try {
      // 从数据库获取用户信息
      const user = await User.fetchFromDatabase(this.account);
      
      if (!user) {
        promptAction.showToast({
          message: '账号不存在',
          duration: 2000
        });
        return;
      }

      // 验证密码
      if (user.getPassword() !== this.password) {
        promptAction.showToast({
          message: '密码错误',
          duration: 2000
        });
        return;
      }

      // 保存或清除账号密码
      if (this.preferences) {
        if (this.rememberPassword) {
          await this.preferences.put('savedAccount', this.account);
          await this.preferences.put('savedPassword', this.password);
          await this.preferences.put('rememberPassword', true);
        } else {
          await this.preferences.delete('savedAccount');
          await this.preferences.delete('savedPassword');
          await this.preferences.put('rememberPassword', false);
        }
        await this.preferences.flush();
      }

      // 更新最后登录时间和登录记录
      const currentTime = new Date();
      user.setLastLoginTime(currentTime);
      user.addLoginRecord(currentTime);
      await user.saveLastLoginTimeToDatabase();
      await user.saveLoginRecordsToDatabase();

      // 登录成功，跳转到主页
      router.push({ 
        url: 'pages/zhuye',
        params: {
          account: this.account
        }
      });
    } catch (error) {
      console.error('登录失败:', error);
      promptAction.showToast({
        message: '登录失败，请稍后重试',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 顶部Logo区域
      Column() {
        Image($r('app.media.logo_ai'))
          .width('60%')
          .height(60)
          .margin({ top: 80, bottom: 20 })
          .objectFit(ImageFit.Contain)

        Text('欢迎回来')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4A4A4A')
          .margin({ bottom: 40 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 输入框区域
      Column() {
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
          .onChange((value) => {
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
          .margin({ bottom: 10 })
          .onChange((value) => {
            this.password = value;
          })

        // 记住密码选项
        Row() {
          Checkbox()
            .select(this.rememberPassword)
            .onChange((isSelected) => {
              this.rememberPassword = isSelected;
              if (!isSelected && this.preferences) {
                // 取消记住密码时，清空保存的账号密码
                this.preferences.delete('savedAccount');
                this.preferences.delete('savedPassword');
                this.preferences.put('rememberPassword', false);
                this.preferences.flush();
                this.account = '';
                this.password = '';
              }
            })
          Text('记住密码')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('85%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 30 })

        // 登录按钮
        Button('登录')
          .width('85%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#E6D5B8')
          .borderRadius(25)
          .margin({ bottom: 20 })
          .onClick(() => {
            this.handleLogin();
          })

        // 注册按钮
        Button('注册新账号')
          .width('85%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FFFFFF')
          .borderRadius(25)
          .fontColor('#666666')
          .border({ width: 1, color: '#E6D5B8' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/sign_in' });
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

