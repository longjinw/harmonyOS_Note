import router from '@ohos.router';
import { LvMarkdownIn } from '@luvi/lv-markdown-in'
import { getAllNotes, Note } from './databaseManager'
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MyNote {
  @State notes: Note[] = []
  @State showPreview: boolean = false
  @State selectedNote: Note | null = null

  aboutToAppear() {
    this.loadNotes()
  }

  async loadNotes() {
    try {
      this.notes = await getAllNotes()
      console.info('加载笔记成功')
    } catch (error) {
      console.error('加载笔记失败:', error)
      promptAction.showToast({
        message: '加载笔记失败',
        duration: 2000
      })
    }
  }

  build() {
    Column() {
      // 笔记列表
      List() {
        ForEach(this.notes, (note: Note) => {
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
      .width('100%')
      .height('100%')
      .padding(10)

      // 预览弹窗
      if (this.showPreview && this.selectedNote) {
        Column() {
          Text(this.selectedNote.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })

          LvMarkdownIn({ text: this.selectedNote.content })
            .width('100%')
            .height('80%')
            .border({ width: 1, color: Color.Gray })

          Button('关闭')
            .width('100%')
            .margin({ top: 10 })
            .onClick(() => {
              this.showPreview = false
              this.selectedNote = null
            })
        }
        .width('90%')
        .height('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
      }
    }
    .width('100%')
    .height('100%')
  }
}