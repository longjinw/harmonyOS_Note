import router from '@ohos.router';
import { LvMarkdownIn } from '@luvi/lv-markdown-in'
import { getAllNotes, Note } from './databaseManager'
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct main_page {
  @State notes: Note[] = []
  @State showPreview: boolean = false
  @State selectedNote: Note | null = null
  @State searchText: string = ''
  @State filteredNotes: Note[] = []

  aboutToAppear() {
    this.loadNotes()
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
    const searchLower = text.toLowerCase()
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
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_public_settings"))
            .width(32)
            .height(32)
        }
        .margin({ right: 16 })
        .width(48)
        .height(48)
        .backgroundColor('#ffffff')
      }
      .width('100%')
      .height('10%')
      .padding({ top: 20 })

      // 分割线
      Divider()
        .strokeWidth(1)
        .color('#ccc')

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索笔记' })
          .width('100%')
          .height(40)
          .margin({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchNotes(value)
          })
      }
      .width('100%')
      .height('10%')
      .padding({ top: 10 })

      // 主内容区域 - 笔记列表
      List() {
        if (this.filteredNotes.length === 0) {
          ListItem() {
            Column() {
              Text(this.searchText ? '未找到相关笔记' : '暂无笔记')
                .fontSize(16)
                .fontColor(Color.Gray)
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
                  .margin({ bottom: 5 })
                
                // 笔记预览
                LvMarkdownIn({ text: note.content })
                  .width('100%')
                  .height(100)
                  .border({ width: 1, color: Color.Gray })
                  .margin({ bottom: 10 })
                  .onClick(() => {
                    this.selectedNote = note
                    this.showPreview = true
                  })

                // 笔记信息
                Row() {
                  Text(note.createTime)
                    .fontSize(12)
                    .fontColor(Color.Gray)
                  Text(note.updateTime)
                    .fontSize(12)
                    .fontColor(Color.Gray)
                    .margin({ left: 10 })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#F5F5DC')
              .borderRadius(10)
              .margin({ bottom: 10 })
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding(10)

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
            .backgroundColor('#F5F5DC')
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
            .backgroundColor('#F5F5DC')
            .onClick(() => {
              router.push({
                url: 'pages/New_note',
                params: {
                  noteId: this.selectedNote?.id,
                  title: this.selectedNote?.title,
                  content: this.selectedNote?.content
                }
              })
            })
            .width('70%')
            .layoutWeight(1)
          }
          .width('100%')
          .padding(10)
          .justifyContent(FlexAlign.SpaceBetween)

          // 笔记内容
          Column() {
            Text(this.selectedNote.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 10 })
            
            LvMarkdownIn({ text: this.selectedNote.content })
              .width('100%')
              .height('100%')
              .border({ width: 1, color: Color.Gray })
          }
          .width('100%')
          .height('100%')
          .padding(10)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }

      // 底部按钮栏
      Row() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Column() {
            Image($r("app.media.ic_files_name_drive"))
              .width(32)
              .height(32)
            Text('笔记')
              .fontSize(12)
          }
          .justifyContent(FlexAlign.Center)
        }
        .width('33%')
        .height('100%')
        .backgroundColor('#FFF5EE')

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Image($r("app.media.ic_public_add"))
            .width(32)
            .height(32)
        }
        .width('33%')
        .height('100%')
        .backgroundColor('#FFF5EE')
        .onClick(() => {
          router.push({ url: 'pages/New_note' });
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Column() {
            Image($r("app.media.ic_gallery_material_select_checkbox"))
              .width(32)
              .height(32)
            Text('代办')
              .fontSize(12)
          }
          .justifyContent(FlexAlign.Center)
        }
        .width('33%')
        .height('100%')
        .backgroundColor('#FFF5EE')
      }
      .width('100%')
      .height('10%')
      .backgroundColor('#ffffff')
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
    }
    .width('100%')
    .height('100%')
  }
}