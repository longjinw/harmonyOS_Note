import router from '@ohos.router';
// test.ets
import { LvMarkdownIn } from '@luvi/lv-markdown-in'
import { createNote } from './databaseManager'
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MarkdownEditor {
  @State textContent: string = ''
  @State previewContent: string = ''
  @State showPreview: boolean = false
  @State title: string = ''
  @State showNavButtons: boolean = true
  @State editorContent: string = ''  // 添加编辑框内容状态

  aboutToAppear() {
    // 初始化 Markdown 内容
    this.textContent = this.title ? this.title : '请输入'
    this.updatePreview()
  }

  updatePreview() {
    // 使用 LvMarkdownIn 处理 Markdown 文本
    this.previewContent = this.editorContent  // 使用编辑框内容更新预览
  }

  async saveNote() {
    try {
      if (!this.title.trim()) {
        promptAction.showToast({
          message: '请输入标题',
          duration: 2000
        });
        return;
      }
      if (!this.editorContent.trim()) {  // 检查编辑框内容
        promptAction.showToast({
          message: '请输入内容',
          duration: 2000
        });
        return;
      }
      await createNote(this.title, this.editorContent);  // 保存编辑框内容
      console.info('savenoteok');  // 添加成功日志
      promptAction.showToast({
        message: '保存成功',
        duration: 2000
      });
      // 保存成功后返回主页
      router.pushUrl({ url: 'pages/zhuye' });
    } catch (error) {
      console.error('保存笔记失败:', error);
      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    }
  }

  build() {
    Stack() {
      Column() {
        // 导航按钮
        if (this.showNavButtons) {
          Row() {
            Button() {
              Image($r('app.media.ic_public_arrow_left_filled'))
                .width(24)
                .height(24)
            }
            .backgroundColor('#F5F5DC')
            .onClick(() => {
              router.pushUrl({ url: 'pages/zhuye' })
            })
            Row() {
              Button() {
                Image($r('app.media.ic_gallery_material_select_checkbox'))
                  .width(24)
                  .height(24)
              }
              .backgroundColor('#F5F5DC')
              .onClick(() => {
                this.saveNote();
              })
            }
            .justifyContent(FlexAlign.End)
            .width('70%')
          }
          .width('100%')
          .padding(10)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        // 标题栏
        Row() {
          TextInput({ placeholder: '请输入标题' })
            .width('85%')
            .onChange((value: string) => {
              this.title = value
            })
          Button() {
            Image(this.showNavButtons ? $r('app.media.ic_public_arrow_up_0') : $r('app.media.ic_public_arrow_down_0'))
              .width(24)
              .height(24)
          }
          .backgroundColor('#F5F5DC')
          .margin({ left: 10 })
          .onClick(() => {
            this.showNavButtons = !this.showNavButtons
          })
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F5F5DC') // 米黄色背景

        // 预览区
        if (this.showPreview) {
          Column() {
            Text('预览区')
              .fontSize(16)
              .margin({ bottom: 5 })
            LvMarkdownIn({ text: this.previewContent })
              .width('100%')
              .height('40%')
              .border({ width: 1, color: Color.Gray })
          }
          .width('100%')
          .padding(10)
        }

        // 编辑区
        Column() {
          TextArea()
            .width('100%')
            .height('60%')
            .fontSize(16)
            .onChange((value: string) => {
              this.editorContent = value  // 更新编辑框内容
              this.updatePreview()
            })
        }
        .width('100%')
        .height('60%')
        .padding(10)
      }
      .width('100%')
      .height('100%')
      .padding(10)

      // 预览按钮
      Button(this.showPreview ? '关闭预览' : '预览')
        .width('100%')
        .height(50)
        .backgroundColor('#F5F5DC') // 米黄色
        .fontColor(Color.Black) // 黑色字体
        .position({ x: 0, y: '100%' })
        .margin({ top: -90 })
        .onClick(() => {
          this.showPreview = !this.showPreview
        })
    }
    .width('100%')
    .height('100%')
  }
}