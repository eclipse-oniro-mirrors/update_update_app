/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 开启自动更新弹框
 */
@CustomDialog
export struct EnableAutoUpdateDialogBuilder {
  controller: CustomDialogController;
  content: ResourceStr = '';
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      Column() {
        Text($r('app.string.setting_auto_update_title'))
          .width('100%')
          .fontSize($r('app.float.text_size_dialog_title'))
          .textAlign(TextAlign.Center)
        Text(this.content)
          .width('100%')
          .fontSize($r('app.float.text_size_dialog_body'))
          .textAlign(TextAlign.Center)
          .margin({
            top: $r('app.float.dialog_margin_top'),
            bottom: $r('app.float.dialog_content_margin_vertical')
          })
      }
      .margin({
        left: $r('app.float.dialog_margin_horizontal'),
        right: $r('app.float.dialog_margin_horizontal')
      })

      Row() {
        Button($r('app.string.cancel'))
          .onClick(() => {
            this.controller.close();
            this.cancel();
          })
          .backgroundColor($r('sys.color.ohos_id_color_dialog_bg_transparent'))
          .fontColor($r('app.color.blue'))
          .height($r('app.float.dialog_button_height'))
          .fontSize($r('app.float.text_size_btn'))
          .layoutWeight(1)
          .padding({ left: '0vp', right: '0vp' })
        Divider()
          .vertical(true)
          .height($r('app.float.dialog_divider_height'))
          .strokeWidth('0.8vp')
          .color($r('app.color.dialog_divider_color'))
          .margin({
            left: $r('app.float.divider_margin'),
            right: $r('app.float.divider_margin')
          })
        Button($r('app.string.enable'))
          .onClick(() => {
            this.controller.close();
            this.confirm();
          })
          .backgroundColor($r('sys.color.ohos_id_color_dialog_bg_transparent'))
          .fontColor($r('app.color.blue'))
          .height($r('app.float.dialog_button_height'))
          .fontSize($r('app.float.text_size_btn'))
          .layoutWeight(1)
          .padding({ left: '0vp', right: '0vp' })
      }
      .margin({
        left: $r('app.float.dialog_row_margin_horizontal'),
        right: $r('app.float.dialog_row_margin_horizontal')
      })
    }
    .margin({
      top: $r('app.float.dialog_margin_top'),
      bottom: $r('app.float.dialog_margin_bottom')
    })
  }
}
