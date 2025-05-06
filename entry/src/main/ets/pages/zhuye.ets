import router from '@ohos.router';
@Entry
@Component
struct main_page {
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
          .width('80%')
          .height(40)
          .margin({ left: 16, right: 8 })

        // 添加搜索按钮到搜索框内
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_public_input_search"))
            .width(24)
            .height(24)
        }
        .width(48)
        .height(48)
        .margin({ right: 16 })
      }
      .width('100%')
      .height('10%')
      .padding({ top: 10 })

      // 主内容区域
      Column() {
        Text('主页内容')
          .fontSize(24)
          .margin({ top: 20 })
      }
      .width('100%')
      .height('50%')

      // 分割线
      Divider()
        .strokeWidth(1)
        .color('#ccc')

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
          router.push({ url: 'pages/New_note' }); // 新增：点击新增按钮跳转到 test 页面
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
      .height('20%')
      .backgroundColor('#ffffff')
      .padding({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }
}