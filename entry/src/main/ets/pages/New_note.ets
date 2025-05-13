import router from '@ohos.router';
import { LvMarkdownIn } from '@luvi/lv-markdown-in'
import { createNote, updateNote } from './databaseManager'
import promptAction from '@ohos.promptAction';
import { ThemeManager } from '../common/ThemeManager';
import emitter from '@ohos.events.emitter';
import { VoiceRecognitionManager } from '../common/VoiceRecognitionManager';


class RouterParams {
  noteId: number = 0;
  title: string = '';
  content: string = '';
  isEdit: boolean = false;
}

@Entry
@Component
struct MarkdownEditor {
  @State textContent: string = ''
  @State previewContent: string = ''
  @State title: string = ''
  @State showNavButtons: boolean = true
  @State editorContent: string = ''
  @State noteId: number = 0
  @State isEdit: boolean = false
  @State showPreview: boolean = true
  @State isRecording: boolean = false
  private themeManager: ThemeManager = ThemeManager.getInstance();
  private voiceManager: VoiceRecognitionManager = VoiceRecognitionManager.getInstance();
 

  async aboutToAppear() {
    let params = router.getParams() as RouterParams;
    if (params) {
      this.noteId = params.noteId ?? 0;
      this.title = params.title ?? '';
      this.editorContent = params.content ?? '';
      this.isEdit = params.isEdit ?? false;
    }
    this.previewContent = this.editorContent;
    this.themeManager.init();
    ThemeManager.subscribeToThemeChange((isDarkMode) => {
      this.updateTheme();
    });
    
    // 初始化语音识别管理器
    try {
      await this.voiceManager.init((text: string) => {
        this.editorContent += text;
        this.previewContent = this.editorContent;
      });
    } catch (error) {
      console.error('初始化语音识别失败:', error);
      promptAction.showToast({
        message: '语音识别初始化失败，请重试',
        duration: 2000
      });
    }
  }

  aboutToDisappear() {
    ThemeManager.unsubscribeFromThemeChange();
    if (this.voiceManager.isRecognizing()) {
      this.voiceManager.stop();
    }
  }

  updateTheme() {
    this.title = this.title;
    this.editorContent = this.editorContent;
    this.previewContent = this.editorContent;
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
      if (!this.editorContent.trim()) {
        promptAction.showToast({
          message: '请输入内容',
          duration: 2000
        });
        return;
      }

      if (this.isEdit && this.noteId) {
        await updateNote(this.noteId, this.title, this.editorContent);
        console.info('更新笔记成功');
      } else {
        await createNote(this.title, this.editorContent);
        console.info('创建笔记成功');
      }

      promptAction.showToast({
        message: this.isEdit ? '更新成功' : '保存成功',
        duration: 2000
      });
      
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
          router.pushUrl({ url: 'pages/zhuye' })
        })

        Text(this.isEdit ? '编辑笔记' : '新建笔记')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeManager.getTextColor())
          .margin({ left: 16 })

        Blank()

        Button() {
          Image($r('app.media.ic_gallery_material_select_checkbox'))
            .width(24)
            .height(24)
        }
        .backgroundColor(this.themeManager.getButtonColor())
        .onClick(() => {
          this.saveNote();
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.themeManager.getCardBackgroundColor())

      // 标题输入框
      TextInput({ placeholder: '请输入标题', text: this.title })
        .width('100%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.themeManager.getCardBackgroundColor())
        .fontColor(this.themeManager.getTextColor())
        .placeholderColor(this.themeManager.getSecondaryTextColor())
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.title = value
        })

      // 主体内容：左右分栏
      Row() {
        // 编辑区域
        Column() {
          TextArea({ text: this.editorContent })
            .width('100%')
            .height('100%')
            .fontSize(16)
            .backgroundColor(this.themeManager.getCardBackgroundColor())
            .fontColor(this.themeManager.getTextColor())
            .borderRadius(20)
            .onChange((value: string) => {
              this.editorContent = value
              this.previewContent = value
            })
        }
        .width(this.showPreview ? '50%' : '100%')
        .height('100%')
        .padding(16)

        // 预览区域
        if (this.showPreview) {
          Column() {
            LvMarkdownIn({ text: this.previewContent })
              .width('100%')
              .height('100%')
              .backgroundColor(this.themeManager.getCardBackgroundColor())
              .border({ width: 1, color: '#CCC' })
              .borderRadius(8)
          }
          .width('50%')
          .height('100%')
          .padding(16)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeManager.getBackgroundColor())

      // 右下角按钮组
      Column() {
        // 预览切换按钮
        Button() {
          Image($r('app.media.foreground'))
            .width(32)
            .height(32)
        }
        .backgroundColor(this.themeManager.getButtonColor())
        .onClick(() => {
          this.showPreview = !this.showPreview;
        })
        .margin({ bottom: 16 })

        // 语音输入按钮
        Button() {
          Image($r('app.media.ic_public_input_voice'))
            .width(32)
            .height(32)
        }
        .backgroundColor(this.voiceManager.isRecognizing() ? '#FF0000' : this.themeManager.getButtonColor())
        .onClick(async () => {
          try {
            if (this.voiceManager.isRecognizing()) {
              this.voiceManager.stop();
            } else {
              this.voiceManager.startListeningFromMic();
            }
          } catch (error) {
            console.error('语音识别操作失败:', error);
            promptAction.showToast({
              message: '语音识别操作失败，请重试',
              duration: 2000
            });
          }
        })
      }
      .position({ x: '90%', y: '85%' })
      .zIndex(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.getBackgroundColor())
  }
}