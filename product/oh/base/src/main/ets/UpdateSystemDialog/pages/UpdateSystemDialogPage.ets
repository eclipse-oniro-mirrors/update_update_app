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

import type common from '@ohos.app.ability.common';
import type UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AlertDialog } from '@kit.ArkUI';
import {
  CountDownDialogType,
  MAIN_ABILITY_NAME,
  NIGHT_UPGRADE_END,
  NIGHT_UPGRADE_START,
  PACKAGE_NAME
} from '@ohos/common/src/main/ets/const/update_const';
import { DeviceUtils } from '@ohos/common/src/main/ets/util/DeviceUtils';
import { FormatUtils } from '@ohos/common/src/main/ets/util/FormatUtils';
import { LogUtils } from '@ohos/common/src/main/ets/util/LogUtils';
import { UpdateUtils } from '@ohos/common/src/main/ets/util/UpdateUtils';
import { CountDownInstallDialogBuilder } from 'ota/src/main/ets/dialog/CountDownInstallDialogBuilder';
import { EnableAutoUpdateDialogBuilder } from 'ota/src/main/ets/dialog/EnableAutoUpdateDialogBuilder';
import { OtaUpdateManager } from 'ota/src/main/ets/manager/OtaUpdateManager';
import {
  SceneBoardDialogType
} from 'ota/src/main/ets/notify/SceneBoardDialogManager';
import VersionUtils from 'ota/src/main/ets/util/VersionUtils';

const TAG = 'UpdateSystemDialogPage';
const storage = LocalStorage.getShared();

@CustomDialog
struct DownloadReminderDialog {
  controller: CustomDialogController;
  versionName: string = '';
  installReady: boolean = false;
  primaryAction: () => void = () => {
  };
  showDetails: () => void = () => {
  };
  later: () => void = () => {
  };

  build() {
    Column({ space: 5 }) {
      Text($r('app.string.software_update'))
        .width('100%')
        .fontSize('20fp')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.black'))
        .textAlign(TextAlign.Center)

      Text(this.installReady ?
        $r('app.string.desktop_install_dialog_content', this.versionName) :
        $r('app.string.desktop_download_dialog_content', this.versionName))
        .width('100%')
        .fontSize('14fp')
        .fontColor($r('app.color.black'))
        .textAlign(TextAlign.Center)
        .margin({ top: '16vp', bottom: '16vp' })

      Button(this.installReady ? $r('app.string.btn_install_immediately') : $r('app.string.btn_download'))
        .width('100%')
        .height('40vp')
        .fontSize('14fp')
        .fontColor($r('app.color.white'))
        .backgroundColor($r('app.color.deep_blue'))
        .borderRadius('20vp')
        .onClick(() => {
          this.primaryAction();
        })

      Button($r('app.string.detail_info'))
        .width('100%')
        .height('36vp')
        .fontSize('14fp')
        .fontColor($r('app.color.deep_blue'))
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showDetails();
        })

      Button($r('app.string.later'))
        .width('100%')
        .height('36vp')
        .fontSize('14fp')
        .fontColor($r('app.color.deep_blue'))
        .backgroundColor(Color.Transparent)
        .margin({ top: '4vp' })
        .onClick(() => {
          this.later();
        })
    }
    .width('100%')
    .padding({ left: '20vp', right: '20vp', top: '20vp', bottom: '12vp' })
  }
}

@Entry(storage)
@Component
struct UpdateSystemDialogPage {
  private session?: UIExtensionContentSession = storage?.get('session') as UIExtensionContentSession;
  private context = getContext(this) as common.UIExtensionContext;
  private dialogType: string = (storage?.get('dialogType') as string) ?? '';
  private actionHandled: boolean = false;
  @State private versionName: string = '';

  private downloadDialogController = new CustomDialogController({
    builder: DownloadReminderDialog({
      versionName: this.versionName,
      primaryAction: () => {
        this.startDownload();
      },
      showDetails: () => {
        this.showDetails();
      },
      later: () => {
        this.handleLater();
      }
    }),
    alignment: DeviceUtils.getDialogLocation(),
    offset: {
      dx: '0vp',
      dy: DeviceUtils.getDialogOffsetY()
    },
    autoCancel: false,
    cancel: () => {
      this.closeSession();
    }
  });

  private installReminderDialogController = new CustomDialogController({
    builder: DownloadReminderDialog({
      versionName: this.versionName,
      installReady: true,
      primaryAction: () => {
        this.installNow();
      },
      showDetails: () => {
        this.showDetails();
      },
      later: () => {
        this.handleInstallLater();
      }
    }),
    alignment: DeviceUtils.getDialogLocation(),
    offset: {
      dx: '0vp',
      dy: DeviceUtils.getDialogOffsetY()
    },
    autoCancel: false,
    cancel: () => {
      this.closeSession();
    }
  });

  private autoDownloadDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.enable_wlan_auto_download_title'),
      content: $r('app.string.enable_wlan_auto_download_content'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          this.closeSession();
        }
      },
      secondaryButton: {
        value: $r('app.string.enable'),
        action: () => {
          this.enableAutoDownload();
        }
      }
    }),
    alignment: DeviceUtils.getDialogLocation(),
    offset: {
      dx: '0vp',
      dy: DeviceUtils.getDialogOffsetY()
    },
    autoCancel: false,
    cancel: () => {
      this.closeSession();
    }
  });

  private installCountdownDialogController = new CustomDialogController({
    builder: CountDownInstallDialogBuilder({
      textString: $r('app.string.count_down_message_recovery', this.versionName, 20),
      dialogType: CountDownDialogType.OTA,
      cancel: () => {
        this.showAutoUpdateDialog();
      },
      confirm: () => {
        this.installNow();
      }
    }),
    alignment: DeviceUtils.getDialogLocation(),
    offset: {
      dx: '0vp',
      dy: DeviceUtils.getDialogOffsetY()
    },
    autoCancel: false,
    cancel: () => {
      this.closeSession();
    }
  });

  private autoUpdateDialogController = new CustomDialogController({
    builder: EnableAutoUpdateDialogBuilder({
      content: $r('app.string.setting_auto_update_description',
        FormatUtils.getDateRangeFormat(NIGHT_UPGRADE_START, NIGHT_UPGRADE_END)),
      cancel: () => {
        this.closeSession();
      },
      confirm: () => {
        this.enableAutoUpdate();
      }
    }),
    alignment: DeviceUtils.getDialogLocation(),
    offset: {
      dx: '0vp',
      dy: DeviceUtils.getDialogOffsetY()
    },
    autoCancel: false,
    cancel: () => {
      this.closeSession();
    }
  });

  aboutToAppear(): void {
    LogUtils.info(TAG, `aboutToAppear, dialogType=${this.dialogType}`);
    if (this.dialogType === SceneBoardDialogType.DOWNLOAD_REMINDER) {
      this.openDownloadReminder();
      return;
    }
    if (this.dialogType === SceneBoardDialogType.INSTALL_COUNTDOWN) {
      this.openInstallCountdown();
      return;
    }
    if (this.dialogType === SceneBoardDialogType.INSTALL_REMINDER) {
      this.openInstallReminder();
      return;
    }
    LogUtils.error(TAG, `Unsupported dialog type: ${this.dialogType}`);
    this.closeSession();
  }

  private async startDownload(): Promise<void> {
    if (this.actionHandled) {
      return;
    }
    this.actionHandled = true;
    try {
      await OtaUpdateManager.getInstance().download();
      LogUtils.info(TAG, 'Start update package download from desktop dialog.');
    } catch (error) {
      LogUtils.error(TAG, `Start update package download failed: ${JSON.stringify(error)}`);
    }
    this.closeSession();
  }

  private async openInstallCountdown(): Promise<void> {
    await this.obtainVersionName();
    this.installCountdownDialogController.open();
  }

  private async openInstallReminder(): Promise<void> {
    await this.obtainVersionName();
    this.installReminderDialogController.open();
  }

  private showAutoUpdateDialog(): void {
    LogUtils.info(TAG, 'Install postponed, show auto-update dialog.');
    this.autoUpdateDialogController.open();
  }

  private handleInstallLater(): void {
    this.installReminderDialogController.close();
    this.showAutoUpdateDialog();
  }

  private async installNow(): Promise<void> {
    if (this.actionHandled) {
      return;
    }
    this.actionHandled = true;
    try {
      await OtaUpdateManager.getInstance().upgrade();
      LogUtils.info(TAG, 'Start update installation from desktop dialog.');
    } catch (error) {
      LogUtils.error(TAG, `Start update installation failed: ${JSON.stringify(error)}`);
    }
    this.closeSession();
  }

  private async enableAutoUpdate(): Promise<void> {
    if (this.actionHandled) {
      return;
    }
    this.actionHandled = true;
    try {
      const upgradePolicy = await OtaUpdateManager.getInstance().getUpdatePolicy();
      upgradePolicy.downloadStrategy = true;
      upgradePolicy.autoUpgradeStrategy = true;
      await OtaUpdateManager.getInstance().setUpdatePolicy(upgradePolicy);
      LogUtils.info(TAG, 'Auto download and night installation enabled.');
    } catch (error) {
      LogUtils.error(TAG, `Enable auto update failed: ${JSON.stringify(error)}`);
    }
    this.closeSession();
  }

  private async openDownloadReminder(): Promise<void> {
    await this.obtainVersionName();
    this.downloadDialogController.open();
  }

  private async obtainVersionName(): Promise<void> {
    try {
      const newVersionResult = await OtaUpdateManager.getInstance().getNewVersion();
      const newVersionInfo = newVersionResult.data;
      this.versionName = newVersionInfo ? await VersionUtils.obtainNewVersionName(newVersionInfo) : '';
      if (!this.versionName) {
        this.versionName = await this.context.resourceManager.getString($r('app.string.title_new_version').id);
      }
    } catch (error) {
      LogUtils.warn(TAG, `Get new version name failed: ${JSON.stringify(error)}`);
      this.versionName = await this.context.resourceManager.getString($r('app.string.title_new_version').id);
    }
  }

  private showDetails(): void {
    if (this.actionHandled) {
      return;
    }
    this.actionHandled = true;
    UpdateUtils.startAbility(this.context, {
      bundleName: PACKAGE_NAME,
      abilityName: MAIN_ABILITY_NAME,
      uri: 'pages/newVersion'
    });
    this.closeSession();
  }

  private async handleLater(): Promise<void> {
    try {
      const upgradePolicy = await OtaUpdateManager.getInstance().getUpdatePolicy();
      if (upgradePolicy.downloadStrategy) {
        this.closeSession();
        return;
      }
      LogUtils.info(TAG, 'Auto download is disabled, show WLAN auto-download dialog.');
      this.downloadDialogController.close();
      this.autoDownloadDialogController.open();
    } catch (error) {
      LogUtils.error(TAG, `Get update policy failed: ${JSON.stringify(error)}`);
      this.closeSession();
    }
  }

  private async enableAutoDownload(): Promise<void> {
    if (this.actionHandled) {
      return;
    }
    this.actionHandled = true;
    try {
      const upgradePolicy = await OtaUpdateManager.getInstance().getUpdatePolicy();
      upgradePolicy.downloadStrategy = true;
      await OtaUpdateManager.getInstance().setUpdatePolicy(upgradePolicy);
      LogUtils.info(TAG, 'WLAN auto download enabled.');
    } catch (error) {
      LogUtils.error(TAG, `Enable WLAN auto download failed: ${JSON.stringify(error)}`);
    }
    this.closeSession();
  }

  private closeSession(): void {
    try {
      this.session?.terminateSelf();
    } catch (error) {
      LogUtils.error(TAG, `Terminate system dialog session failed: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#00000000')
  }
}
