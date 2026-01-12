import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  LengthMetrics,
  LengthUnit,
  PromptAction
} from '@kit.ArkUI';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CustomDialog } from '../components/CustomDialog';

@ComponentV2
export struct TimerView {
  @Local timerId: number = -1;
  @Local seconds: number = 0;
  @Local toastId: number = 0;
  @Local bottomOptions: ArcButtonOptions = new ArcButtonOptions({});
  @Local customDialogComponentId: number = 0
  context: UIContext = this.getUIContext();
  prompt: PromptAction = this.context.getPromptAction();

  @Builder
  customDialogBuilder() {
    CustomDialog({
      customDialogComponentId: this.customDialogComponentId,
      onSelect: async (seconds: number) => {
        this.seconds = seconds;
        await this.startTimer();
      }
    })
  }

  onDialogHandler() {
    this.prompt.openCustomDialog({
      builder: () => {
        this.customDialogBuilder();
      },
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        console.info(`reason: ${JSON.stringify(dismissDialogAction.reason)}`)
        console.info('dialog onWillDismiss')
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      }
    }).then((dialogId: number) => {
      this.customDialogComponentId = dialogId
    }).catch((error: BusinessError) => {
      console.error(`openCustomDialog error code is ${error.code}, message is ${error.message}`)
    })
  }

  aboutToAppear() {
    this.bottomOptions = new ArcButtonOptions({
      label: 'Set Timer',
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      fontSize: new LengthMetrics(15, LengthUnit.FP),
      shadowEnabled: true,
      onClick: () => this.onDialogHandler()
    })
  }

  async startTimer() {
    let reason = 'Turn room light off';
    try {
      let token = backgroundTaskManager.requestSuspendDelay(reason, () => {
        if (this.timerId !== -1) {
          clearTimeout(this.timerId);
        }
      });

      console.info(`Suspend delay token: ${token}`);
      this.timerId = setTimeout(() => {
        this.seconds = 0;
        this.prompt.openToast({
          message: 'Task Executed',
          duration: 10000
        }).then((toastId: number) => {
          this.toastId = toastId;
        });
      }, this.seconds * 1000);

      console.info(`Task started after ${this.seconds} seconds in background`);
      backgroundTaskManager.cancelSuspendDelay(token.requestId);
    } catch (error) {
      console.error(`Operation requestSuspendDelay failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
  }

  build() {
    Column() {
      Blank().layoutWeight(1)
      Text(`Timer is set to ${this.seconds} seconds.\n A toast will be executed \n after ${this.seconds} seconds`)
      Blank().layoutWeight(1)
      ArcButton({ options: this.bottomOptions })
    }
    .height('100%')
    .width('100%')
  }
}
