/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import AbilityStage from '@ohos.app.ability.AbilityStage';
import { LogUtils } from '@ohos/common/src/main/ets/util/LogUtils';

/**
 * Stage
 *
 * @since 2022-06-06
 */
export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    LogUtils.log('MyAbilityStage', 'onCreate');
    globalThis.stageContext = this.context;

    // 初始化 AppStorage ，避免出现undefined
    AppStorage.SetOrCreate('updateStatus', 0);
    AppStorage.SetOrCreate('downloadProgress', 0);
    AppStorage.SetOrCreate('isClickInstall', 0);
    AppStorage.SetOrCreate('configLanguage', '');
    AppStorage.SetOrCreate('installStatusRefresh', '');
  }
}