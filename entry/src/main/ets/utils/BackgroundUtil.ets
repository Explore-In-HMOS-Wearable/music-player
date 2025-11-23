import { wantAgent, common } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { audioDomain, audioPrefix } from './MediaController';

const TAG = 'BackgroundUtil';

export class BackgroundUtil {
  /**
   * Start background task.
   *
   * @param context
   */
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      hilog.error(audioDomain, audioPrefix, TAG + `startContinuousTask failed context undefined`);
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: Object) => {
      try {
        backgroundTaskManager.startBackgroundRunning(context,
          backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
          hilog.info(audioDomain, audioPrefix, TAG + ' this mediaController: startBackgroundRunning succeeded');
        }).catch((error: BusinessError) => {
          hilog.error(audioDomain, audioPrefix, TAG + ` this mediaController: startBackgroundRunning failed Cause: code ${error.code}, message: ${error.message}`);
        });
      } catch (error) {
        hilog.error(audioDomain, audioPrefix, TAG +
          `startBackgroundRunning failed.message ${(error as BusinessError).message}`);
      }
    });
  }

  /**
   * Stop background task.
   *
   * @param context
   */
  public static stopContinuousTask(context: common.UIAbilityContext): void {
    try {
      backgroundTaskManager.stopBackgroundRunning(context).then(() => {
        hilog.info(audioDomain, audioPrefix, TAG + 'this audioRenderer: stopBackgroundRunning succeeded');
      }).catch((error: BusinessError) => {
        hilog.error(audioDomain, audioPrefix, TAG + `this audioRenderer: stopBackgroundRunning failed Cause: code ${error.code}`);
      });
    } catch (error) {
      hilog.error(audioDomain, audioPrefix, TAG +
        `stopBackgroundRunning failed. message ${(error as BusinessError).message}`);
    }
  }
}