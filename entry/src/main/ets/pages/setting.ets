import router from '@ohos.router';
import { ThemeManager } from '../common/ThemeManager';
import promptAction from '@ohos.promptAction';

interface AppInfo {
  version: string;
  team: string[];
  updateLog: string[];
}

@Entry
@Component
struct SettingPage {
  @State isDarkMode: boolean = false;
  private themeManager: ThemeManager = ThemeManager.getInstance();
  private readonly appInfo: AppInfo = {
    version: '1.0.0',
    team: [
      '产品经理: XXX',
      '开发人员: XXX',
      '设计人员: XXX'
    ],
    updateLog: [
      '2024-01: 1.0.0版本发布',
      '- 支持Markdown编辑',
      '- 支持深色模式',
      '- 支持语音输入',
      '- 支持待办功能'
    ]
  };

  aboutToAppear() {
    this.themeManager.init();
    this.isDarkMode = this.themeManager.isDark();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.ic_public_arrow_left_filled'))
            .width(24)
            .height(24)
        }
        .backgroundColor(this.themeManager.getButtonColor())
        .onClick(() => {
          router.back();
        })

        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeManager.getTextColor())
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.themeManager.getCardBackgroundColor())

      // 设置选项列表
      List() {
        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_files_name_drive'))
                .width(24)
                .height(24)
                .margin({ right: 12 })
                .fillColor(this.themeManager.getTextColor())
              Text('主题设置')
                .fontSize(16)
                .fontColor(this.themeManager.getTextColor())
            }
            Row() {
              Text(this.isDarkMode ? '深色' : '浅色')
                .fontSize(14)
                .fontColor(this.themeManager.getSecondaryTextColor())
                .margin({ right: 8 })
              Image($r('app.media.ic_public_arrow_down_0'))
                .width(20)
                .height(20)
                .fillColor(this.themeManager.getSecondaryTextColor())
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(16)
          .backgroundColor(this.themeManager.getCardBackgroundColor())
          .onClick(() => {
            this.showThemeDialog();
          })
        }

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_gallery_material_select_checkbox'))
                .width(24)
                .height(24)
                .margin({ right: 12 })
                .fillColor(this.themeManager.getTextColor())
              Text('关于我们')
                .fontSize(16)
                .fontColor(this.themeManager.getTextColor())
            }
            Image($r('app.media.ic_public_arrow_down_0'))
              .width(20)
              .height(20)
              .fillColor(this.themeManager.getSecondaryTextColor())
              .rotate({ angle: 270 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(16)
          .backgroundColor(this.themeManager.getCardBackgroundColor())
          .onClick(() => {
            this.showAboutDialog();
          })
        }
      }
      .width('100%')
      .margin({ top: 12 })
      .divider({ strokeWidth: 1, color: this.themeManager.isDark() ? '#333333' : '#F5F5F5' })
      .backgroundColor(this.themeManager.getCardBackgroundColor())
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.getBackgroundColor())
  }

  private showThemeDialog() {
    AlertDialog.show({
      title: '选择主题',
      message: '当前主题：' + (this.isDarkMode ? '深色模式' : '浅色模式'),
      primaryButton: {
        value: '浅色模式',
        action: async () => {
          if (this.isDarkMode) {
            await this.themeManager.toggleTheme();
            this.isDarkMode = false;
          }
        }
      },
      secondaryButton: {
        value: '深色模式',
        action: async () => {
          if (!this.isDarkMode) {
            await this.themeManager.toggleTheme();
            this.isDarkMode = true;
          }
        }
      },
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      gridCount: 3
    })
  }

  private showAboutDialog() {
    AlertDialog.show({
      title: '关于我们',
      message: this.getAboutMessage(),
      confirm: {
        value: '确定',
        action: () => {
          console.info('关闭关于我们对话框');
        }
      },
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      gridCount: 3
    })
  }

  private getAboutMessage(): string {
    let message = `版本：${this.appInfo.version}\n\n`;
    message += '制作团队：\n';
    message += this.appInfo.team.join('\n');
    message += '\n\n更新日志：\n';
    message += this.appInfo.updateLog.join('\n');
    return message;
  }
} 