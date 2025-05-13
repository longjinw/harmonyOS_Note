import router from '@ohos.router';
import { LvMarkdownIn } from '@luvi/lv-markdown-in'
import { getAllNotes, Note } from './databaseManager'
import promptAction from '@ohos.promptAction';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import display from '@ohos.display';
import { ThemeManager } from '../common/ThemeManager';

@Entry
@Component
struct main_page {
  @State notes: Note[] = []
  @State showPreview: boolean = false
  @State selectedNote: Note | null = null
  @State searchText: string = ''
  @State filteredNotes: Note[] = []
  private themeManager: ThemeManager = ThemeManager.getInstance();

  aboutToAppear() {
    this.loadNotes();
    this.themeManager.init();
    // 订阅主题变化事件
    ThemeManager.subscribeToThemeChange((isDarkMode) => {
      // 主题变化时刷新页面
      this.updateTheme();
    });
  }

  aboutToDisappear() {
    // 取消订阅
    ThemeManager.unsubscribeFromThemeChange();
  }

  updateTheme() {
    // 强制刷新页面
    this.notes = [...this.notes];
  }

  async loadNotes() {
    try {
      this.notes = await getAllNotes()
      this.filteredNotes = this.notes
      console.info('加载笔记成功')
    } catch (error) {
      console.error('加载笔记失败:', error)
      promptAction.showToast({
        message: '加载笔记失败',
        duration: 2000
      })
    }
  }

  searchNotes(text: string) {
    this.searchText = text
    if (!text.trim()) {
      this.filteredNotes = this.notes
      return
    }
    const searchLower: string = text.toLowerCase()
    this.filteredNotes = this.notes.filter(note => 
      note.title.toLowerCase().includes(searchLower) || 
      note.content.toLowerCase().includes(searchLower)
    )
  }

  build() {
    Column() {
      // 顶部标题栏
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text('NOTE')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeManager.getTextColor())
          .margin({ left: 20 })

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_public_settings"))
            .width(28)
            .height(28)
        }
        .margin({ right: 20 })
        .width(44)
        .height(44)
        .backgroundColor(this.themeManager.getButtonColor())
        .onClick(() => {
          router.push({ url: 'pages/setting' });
        })
      }
      .width('100%')
      .height('12%')
      .padding({ top: 20 })
      .backgroundColor(this.themeManager.getCardBackgroundColor())

      // 搜索框
      Row() {
        Image($r('app.media.ic_files_name_drive'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .fillColor(this.themeManager.getTextColor())
        TextInput({ placeholder: '搜索笔记' })
          .width('85%')
          .height(40)
          .margin({ left: 8, right: 16 })
          .backgroundColor(this.themeManager.getSearchBackgroundColor())
          .borderRadius(20)
          .placeholderColor(this.themeManager.getSecondaryTextColor())
          .fontColor(this.themeManager.getTextColor())
          .onChange((value: string) => {
            this.searchNotes(value)
          })
      }
      .width('100%')
      .height('8%')
      .padding({ top: 10 })
      .backgroundColor(this.themeManager.getCardBackgroundColor())

      // 主内容区域 - 笔记列表
      List() {
        if (this.filteredNotes.length === 0) {
          ListItem() {
            Column() {
              Text(this.searchText ? '未找到相关笔记' : '暂无笔记')
                .fontSize(16)
                .fontColor(this.themeManager.getSecondaryTextColor())
                .margin({ top: 20 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
        } else {
          ForEach(this.filteredNotes, (note: Note) => {
            ListItem() {
              Column() {
                // 笔记标题
                Text(note.title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeManager.getTextColor())
                  .margin({ bottom: 8 })
                
                // 笔记预览
                LvMarkdownIn({ text: note.content })
                  .width('100%')
                  .height(100)
                  .borderRadius(8)
                  .backgroundColor(this.themeManager.getNotePreviewBackgroundColor())
                  .margin({ bottom: 12 })
                  .onClick(() => {
                    this.selectedNote = note
                    this.showPreview = true
                  })

                // 笔记信息
                Row() {
                  Text(note.createTime)
                    .fontSize(12)
                    .fontColor(this.themeManager.getSecondaryTextColor())
                  Text(note.updateTime)
                    .fontSize(12)
                    .fontColor(this.themeManager.getSecondaryTextColor())
                    .margin({ left: 10 })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeManager.getCardBackgroundColor())
              .borderRadius(12)
              .margin({ bottom: 12 })
              .shadow({ radius: 6, color: this.themeManager.isDark() ? '#000000' : '#1A000000', offsetX: 2, offsetY: 4 })
            }
          })
        }
      }
      .width('100%')
      .height('80%')
      .padding({ left: 16, right: 16 })

      // 预览弹窗
      if (this.showPreview && this.selectedNote) {
        Column() {
          // 顶部导航栏
          Row() {
            // 返回按钮
            Button() {
              Image($r('app.media.ic_public_arrow_left_filled'))
                .width(24)
                .height(24)
            }
            .backgroundColor(this.themeManager.getButtonColor())
            .onClick(() => {
              this.showPreview = false
              this.selectedNote = null
            })

            // 编辑按钮
            Button() {
              Image($r('app.media.ic_files_name_drive'))
                .width(24)
                .height(24)
            }
            .backgroundColor(this.themeManager.getButtonColor())
            .onClick(() => {
              router.push({
                url: 'pages/New_note',
                params: {
                  noteId: this.selectedNote?.id,
                  title: this.selectedNote?.title,
                  content: this.selectedNote?.content,
                  isEdit: true
                }
              })
            })
          }
          .width('100%')
          .padding(10)
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor(this.themeManager.getCardBackgroundColor())

          // 笔记内容
          Column() {
            Text(this.selectedNote.title)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeManager.getTextColor())
              .margin({ bottom: 20 })
            
            LvMarkdownIn({ text: this.selectedNote.content })
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height('100%')
          .padding(20)
          .backgroundColor(this.themeManager.getCardBackgroundColor())
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeManager.getBackgroundColor())
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }

      // 待办按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Image($r("app.media.ic_public_arrow_right"))
          .width(32)
          .height(32)
      }
      .width(60)
      .height(60)
      .borderRadius(30)
      .backgroundColor(this.themeManager.getButtonColor())
      .position({ x: '100%', y: '100%' })
      .translate({ x: -80, y: -160 })  // y值设置为新建按钮的两倍，确保在其上方
      .shadow({ radius: 8, color: this.themeManager.isDark() ? '#000000' : '#1A000000', offsetX: 0, offsetY: 4 })
      .onClick(() => {
        router.push({ url: 'pages/todo' });
      })

      // 浮动新建按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Image($r("app.media.ic_public_add"))
          .width(32)
          .height(32)
      }
      .width(60)
      .height(60)
      .borderRadius(30)
      .backgroundColor(this.themeManager.getButtonColor())
      .position({ x: '100%', y: '100%' })
      .translate({ x: -80, y: -80 })
      .shadow({ radius: 8, color: this.themeManager.isDark() ? '#000000' : '#1A000000', offsetX: 0, offsetY: 4 })
      .onClick(() => {
        router.push({ url: 'pages/New_note' });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.getBackgroundColor())
  }
}