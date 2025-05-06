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
      // Logo 图片
      Image($r('app.media.logo_ai'))
        .width('80%')
        .height(50)
        .margin({ top: 50, bottom: 20 })
        .objectFit(ImageFit.Contain)

      TextInput({ placeholder: '请输入账号', text: this.account })
        .width('80%')
        .height(50)
        .margin({ top: 20 })
        .backgroundColor('#F5DEB3') // 米黄色背景
        .fontColor(Color.White) // 白色字体
        .placeholderColor(Color.White) // 白色占位符
        .onChange((value) => {
          this.account = value;
        });

      TextInput({ placeholder: '请输入密码', text: this.password })
        .width('80%')
        .height(50)
        .margin({ top: 20 })
        .backgroundColor('#F5DEB3') // 米黄色背景
        .fontColor(Color.White) // 白色字体
        .placeholderColor(Color.White) // 白色占位符
        .type(InputType.Password)
        .onChange((value) => {
          this.password = value;
        });

      // 记住密码选择框
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
        Text('记住密码') // 注释：是否下次免输入密码
          .fontSize(14)
          .margin({ left: 8 })
      }
      .width('80%')
      .margin({ top: 10 })
      .justifyContent(FlexAlign.Start)

      Button('登录')
        .width('80%')
        .height(50)
        .margin({ top: 30 })
        .onClick(() => {
          this.handleLogin();
        });

      // 注册按钮
      Button('注册')
        .width('80%')
        .height(50)
        .margin({ top: 10 })
        .onClick(() => {
          // 跳转到注册页面
          router.pushUrl({ url: 'pages/sign_in' });
        });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}

