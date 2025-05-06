// test.ets
import { LvMarkdownIn } from '@luvi/lv-markdown-in'

@Entry
@Component
struct MarkdownEditor {
  @State textContent: string = ''
  @State previewContent: string = ''

  aboutToAppear() {
    // 初始化 Markdown 内容
    this.textContent = '# 欢迎使用 Markdown 编辑器\n\n这是一个示例文本。'
    this.updatePreview()
  }

  updatePreview() {
    // 使用 LvMarkdownIn 处理 Markdown 文本
    this.previewContent = this.textContent
  }

  build() {
    Column() {
      // 标题
      Text('Markdown 编辑器')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })

      // 编辑区域
      Row() {
        // 编辑区
        Column() {
          Text('编辑区')
            .fontSize(16)
            .margin({ bottom: 5 })
          TextArea()
            .width('100%')
            .height(300)
            .fontSize(16)
            .onChange((value: string) => {
              this.textContent = value
              this.updatePreview()
            })
        }
        .width('50%')
        .padding(10)

        // 预览区
        Column() {
          Text('预览区')
            .fontSize(16)
            .margin({ bottom: 5 })
          LvMarkdownIn({ text: this.previewContent })
            .width('100%')
            .height(300)
            .border({ width: 1, color: Color.Gray })
        }
        .width('50%')
        .padding(10)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding(10)
  }
}
