import router from '@ohos.router';
import { User } from '../my_class/user';

@Entry
@Component
struct SignIn {
  @State nickname: string = '';
  @State account: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';

  build() {
    Column({ space: 15 }) {
      TextInput({ placeholder: '请输入昵称' })
        .onEditChange((isEditing: boolean) => {
          if (!isEditing) {
            this.nickname = this.nickname; // 保持状态不变，因为 onEditChange 只接收 isEditing 参数
          }
        })
        .onChange((value: string) => {
          this.nickname = value; // 使用 onChange 来更新状态
        })
        .width('100%')
        .margin({ bottom: 15 })
        .placeholderColor('#999999')
        .placeholderFont({ size: 14, weight: FontWeight.Regular });

      TextInput({ placeholder: '请输入账号' })
        .onEditChange((isEditing: boolean) => {
          if (!isEditing) {
            this.account = this.account; // 保持状态不变，因为 onEditChange 只接收 isEditing 参数
          }
        })
        .onChange((value: string) => {
          this.account = value; // 使用 onChange 来更新状态
        })
        .width('100%')
        .margin({ bottom: 15 })
        .placeholderColor('#999999')
        .placeholderFont({ size: 14, weight: FontWeight.Regular });

      TextInput({ placeholder: '请输入密码' })
        .onEditChange((isEditing: boolean) => {
          if (!isEditing) {
            this.password = this.password; // 保持状态不变，因为 onEditChange 只接收 isEditing 参数
          }
        })
        .onChange((value: string) => {
          this.password = value; // 使用 onChange 来更新状态
        })
        .type(InputType.Password)
        .width('100%')
        .margin({ bottom: 15 })
        .placeholderColor('#999999')
        .placeholderFont({ size: 14, weight: FontWeight.Regular });

      TextInput({ placeholder: '请再次输入密码' })
        .onEditChange((isEditing: boolean) => {
          if (!isEditing) {
            this.confirmPassword = this.confirmPassword; // 保持状态不变，因为 onEditChange 只接收 isEditing 参数
          }
        })
        .onChange((value: string) => {
          this.confirmPassword = value; // 使用 onChange 来更新状态
        })
        .type(InputType.Password)
        .width('100%')
        .margin({ bottom: 15 })
        .placeholderColor('#999999')
        .placeholderFont({ size: 14, weight: FontWeight.Regular });

      Button('确认')
        .width('100%')
        .onClick(async () => {
          await this.handleRegister();
        });
    }
    .height('100%')
    .width('100%')
    .padding(20);
  }

  private async handleRegister() {
    if (this.password !== this.confirmPassword) {
      console.error('Passwords do not match');
      return;
    }

    try {
      // 检查账号是否已存在
      const existingUser = await User.fetchFromDatabase(this.account);
      if (existingUser) {
        console.error('Account already exists');
        return;
      }

      // 创建新用户实例
      const currentTime = new Date();
      const newUser = new User(
        this.nickname,
        this.account,
        this.password,
        currentTime, // 注册时间
        currentTime, // 最后登录时间
        [currentTime] // 登录记录
      );

      // 保存用户数据到数据库
      await newUser.saveToDatabase();

      // 输出注册成功信息
      console.log('User registered successfully');
      console.log('User ID:', newUser.id);
      console.log('Nickname:', newUser.nickname);
      console.log('Password:', newUser.password);

      // 跳转到注册成功页面
      router.push({
        url: 'pages/register_success',
        params: {
          nickname: this.nickname,
          account: this.account
        }
      });
    } catch (error) {
      console.error('Failed to save user information:', error);
      console.error('Registration failed, please check your input or try again later');
    }
  }
}
