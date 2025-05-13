import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import emitter from '@ohos.events.emitter';
import window from '@ohos.window';
import bundleManager from '@ohos.bundle.bundleManager';
import Want from '@ohos.app.ability.Want';

// 定义主题事件数据的接口
interface ThemeEventData {
  isDarkMode: boolean;
}

// 定义事件数据的接口
interface ThemeEvent {
  data: ThemeEventData;
}

// 定义事件订阅回调类型
type ThemeCallback = (isDarkMode: boolean) => void;

export class ThemeManager {
  private static instance: ThemeManager;
  private preferences: preferences.Preferences | null = null;
  private isDarkMode: boolean = false;
  private static readonly THEME_CHANGE_EVENT_ID = 'theme_change_event';
  private static readonly THEME_PREFERENCES_NAME = 'theme_settings';
  private static readonly THEME_KEY = 'isDarkMode';

  private constructor() {
    // 初始化时立即加载主题设置
    this.init();
  }

  public static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  public async init() {
    const context = getContext() as common.UIAbilityContext;
    try {
      this.preferences = await preferences.getPreferences(context, ThemeManager.THEME_PREFERENCES_NAME);
      const savedTheme = await this.preferences.get(ThemeManager.THEME_KEY, false);
      this.isDarkMode = Boolean(savedTheme);
      // 初始化时应用主题
      await this.applyTheme();
      // 初始化时也发送一次主题变化事件
      this.notifyThemeChange();
    } catch (error) {
      console.error('初始化主题设置失败:', error);
    }
  }

  public isDark(): boolean {
    return this.isDarkMode;
  }

  public async toggleTheme() {
    // 立即更新主题状态
    this.isDarkMode = !this.isDarkMode;
    
    // 保存设置
    if (this.preferences) {
      try {
        await this.preferences.put(ThemeManager.THEME_KEY, this.isDarkMode);
        await this.preferences.flush();
      } catch (error) {
        console.error('保存主题设置失败:', error);
      }
    }

    // 重启应用
    await this.restartApplication();
  }

  private async restartApplication() {
    try {
      const context = getContext() as common.UIAbilityContext;
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const want: Want = {
        bundleName: bundleInfo.name,
        abilityName: context.abilityInfo.name,
        action: 'action.system.home',
        parameters: {
          // 添加一个时间戳参数，确保每次重启都是新的实例
          timestamp: new Date().getTime()
        }
      };
      
      // 启动新的实例
      await context.startAbility(want);
      // 关闭当前实例
      await context.terminateSelf();
    } catch (error) {
      console.error('重启应用失败:', error);
    }
  }

  private async applyTheme() {
    try {
      const context = getContext() as common.UIAbilityContext;
      const windowClass = await window.getLastWindow(context);
      if (windowClass) {
        // 设置状态栏颜色
        await windowClass.setWindowSystemBarProperties({
          statusBarContentColor: this.isDarkMode ? '#FFFFFF' : '#000000',
          statusBarColor: this.isDarkMode ? '#1A1A1A' : '#FFFFFF',
          navigationBarContentColor: this.isDarkMode ? '#FFFFFF' : '#000000',
          navigationBarColor: this.isDarkMode ? '#1A1A1A' : '#FFFFFF'
        });
      }
    } catch (error) {
      console.error('应用主题失败:', error);
    }
  }

  private notifyThemeChange() {
    const eventData: ThemeEvent = {
      data: {
        isDarkMode: this.isDarkMode
      }
    };
    // 使用同步方式发送事件
    try {
      emitter.emit(ThemeManager.THEME_CHANGE_EVENT_ID, eventData);
    } catch (error) {
      console.error('发送主题变化事件失败:', error);
    }
  }

  public static subscribeToThemeChange(callback: ThemeCallback): void {
    try {
      emitter.on(ThemeManager.THEME_CHANGE_EVENT_ID, (eventData: ThemeEvent) => {
        callback(eventData.data.isDarkMode);
      });
    } catch (error) {
      console.error('订阅主题变化事件失败:', error);
    }
  }

  public static unsubscribeFromThemeChange(): void {
    try {
      emitter.off(ThemeManager.THEME_CHANGE_EVENT_ID);
    } catch (error) {
      console.error('取消订阅主题变化事件失败:', error);
    }
  }

  public getBackgroundColor(): string {
    return this.isDarkMode ? '#1A1A1A' : '#FFFFFF';
  }

  public getCardBackgroundColor(): string {
    return this.isDarkMode ? '#1A1A1A' : '#FFFFFF';
  }

  public getTextColor(): string {
    return this.isDarkMode ? '#FFFFFF' : '#333333';
  }

  public getSecondaryTextColor(): string {
    return this.isDarkMode ? '#CCCCCC' : '#666666';
  }

  public getButtonColor(): string {
    return this.isDarkMode ? '#E6D5B8' : '#E6D5B8';
  }

  public getSearchBackgroundColor(): string {
    return this.isDarkMode ? '#3C3C3C' : '#F5F5F5';
  }

  public getNotePreviewBackgroundColor(): string {
    return this.isDarkMode ? '#3C3C3C' : '#F8F8F8';
  }

  public getBorderColor(): string {
    return this.isDarkMode ? '#3C3C3C' : '#E5E5E5';
  }

  public getShadowColor(): string {
    return this.isDarkMode ? '#000000' : '#1A000000';
  }

  public getPlaceholderColor(): string {
    return this.isDarkMode ? '#999999' : '#999999';
  }

  public getDividerColor(): string {
    return this.isDarkMode ? '#333333' : '#F5F5F5';
  }

  public getStatusBarColor(): string {
    return this.isDarkMode ? '#1A1A1A' : '#FFFFFF';
  }

  public getNavigationBarColor(): string {
    return this.isDarkMode ? '#1A1A1A' : '#FFFFFF';
  }

  public getStatusBarContentColor(): string {
    return this.isDarkMode ? '#FFFFFF' : '#000000';
  }

  public getNavigationBarContentColor(): string {
    return this.isDarkMode ? '#FFFFFF' : '#000000';
  }
} 