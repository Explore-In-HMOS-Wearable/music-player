import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { SongData } from '../viewmodel/SongData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AVSessionController } from './AVSessionController';
import { MediaTools } from './MediaTools';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BackgroundUtil } from './BackgroundUtil';

export const audioDomain: number = 0xFF00;

export const audioPrefix: string = 'MusicPlay';

export class MediaController {
  private player: media.AVPlayer | undefined = undefined
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private songList: SongData[] = [];
  private avSessionController: AVSessionController | undefined = undefined;
  private musicIndex: number = 0;
  private curMs: number = 0;
  private isFirst: boolean = true;

  constructor() {
    let list: SongData[] | undefined = AppStorage.get('songList');
    if (list) {
      this.songList = list;
    }
    this.initAVPlayer()
  }

  public static getInstance(): MediaController {
    let mediaController: MediaController | undefined = AppStorage.get('mediaController');
    if (!mediaController) {
      hilog.debug(audioDomain, audioPrefix, `mediaController is undefined in getInstance()`)
      mediaController = new MediaController();
      AppStorage.setOrCreate<MediaController>('mediaController', mediaController);
    }
    hilog.debug(audioDomain, audioPrefix, `mediaController is ${mediaController}`)
    return mediaController;
  }

  private async initAVPlayer() {
    this.player = await media.createAVPlayer();
    this.player.audioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0
    };
    this.avSessionController = AVSessionController.getInstance();
    hilog.info(audioDomain, audioPrefix, 'Invoke createAVPlayer succeeded.');
    this.setPlayerCallbacks(this.player);
  }

  private setPlayerCallbacks(player: media.AVPlayer) {
    if (!player) {
      hilog.error(audioDomain, audioPrefix, 'writeData fail player is undefined');
      return;
    }

    // audioManager.getVolumeManager().getVolumeGroupManager(LOCAL_VOLUME_GROUP_ID)

    // audio.DEFAULT_VOLUME_GROUP_ID

    player.on('error', this.errorCallback);
    player.on('stateChange', this.stateChangeCallback);
    player.on('timeUpdate', this.timeUpdateCallback);
    player.on('durationUpdate', this.durationUpdateCallback);
    player.on('audioInterrupt', this.interruptCallback);
    player.on('audioOutputDeviceChangeWithInfo', this.outputDeviceChangeCallback);
  }

  private errorCallback: (err: BusinessError) => void = (err: BusinessError) => {
    hilog.error(audioDomain, audioPrefix, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    this.player?.reset(); // reset the AVPlayer, which enters the idle state.
  }
  private stateChangeCallback: (state: string, reason: media.StateChangeReason) => void =
    async (state: string, _reason: media.StateChangeReason) => {
      hilog.info(audioDomain, audioPrefix, `In state ==> ${state}`);
      switch (state) {
        case 'idle':
          break;
        case 'initialized':
          this.player?.prepare();
          break;
        case 'prepared':
          await this.player?.play();
          this.avSessionController?.setAVMetadata();
          break;
        case 'playing':
          this.updateIsPlay(true);
          break;
        case 'paused':
          this.updateIsPlay(true);
          break;
        case 'completed':
          this.playNext()
          break;
        case 'stopped':
          break;
        case 'released':
          break;
        default:
          break;
      }
    }
  private timeUpdateCallback: (time: number) => void = (time: number) => {
    this.updateProgress(time);
  }
  private durationUpdateCallback: (duration: number) => void = (duration: number) => {
    hilog.info(audioDomain, audioPrefix, `total duration: ${duration}`);

    AppStorage.setOrCreate('totalMsTime', duration);
    AppStorage.setOrCreate('totalTime', MediaTools.msToCountdownTime(duration));
    AppStorage.setOrCreate('progressMax', duration);
  }
  private interruptCallback: (interruptEvent: audio.InterruptEvent) => void =
    (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            this.updateIsPlay(false);
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.updateIsPlay(false);
            this.pause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            break;
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            this.loadSongUrl();
            break;
          default:
            break;
        }
      }
    }
  private outputDeviceChangeCallback: (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => void =
    (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => {
      hilog.info(audioDomain, audioPrefix, `DeviceInfo id: ${deviceChangeInfo.devices[0].id}`);
      hilog.info(audioDomain, audioPrefix, `DeviceInfo name: ${deviceChangeInfo.devices[0].name}`);
      hilog.info(audioDomain, audioPrefix, `DeviceInfo address: ${deviceChangeInfo.devices[0].address}`);
      hilog.info(audioDomain, audioPrefix, `Device change reason: ${deviceChangeInfo.changeReason}`);
      if (deviceChangeInfo.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        hilog.info(audioDomain, audioPrefix, `Device change reason: ${deviceChangeInfo.changeReason}`);
        this.pause();
      }
    }

  private updateIsPlay(isPlay: boolean) {
    AppStorage.setOrCreate<boolean>('isPlay', isPlay);
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setPlayState(isPlay);
  }

  private updateProgress(ms: number) {
    this.curMs = ms;
    AppStorage.setOrCreate('progress', this.curMs);
    AppStorage.setOrCreate('currentTime', MediaTools.msToCountdownTime(this.curMs));
    if (!this.avSessionController) {
      return;
    }

    this.avSessionController.setProgressState(ms);
  }

  /**
   * Pause music.
   */
  public async pause() {
    if (!this.player) {
      return;
    }

    try {
      this.player.pause()
        .then(() => {
          this.updateIsPlay(false);
          hilog.info(audioDomain, audioPrefix, 'pause success');
        })
        .catch((err: BusinessError) => {
          hilog.error(audioDomain, audioPrefix, `pause failed, code is ${err.code}, message is ${err.message}}`);
        })
    } catch (e) {
      hilog.error(audioDomain, audioPrefix, `pause failed, undefined pause error`);
    }
  }

  /**
   * Resume music
   */
  public async resume() {
    if (!this.player) {
      return;
    }
    try {
      this.player.play()
        .then(() => {
          this.updateIsPlay(true);
          BackgroundUtil.startContinuousTask(this.context);
          hilog.info(audioDomain, audioPrefix, 'resume success');
        })
        .catch((err: BusinessError) => {
          hilog.error(audioDomain, audioPrefix, `resume failed,code is ${err.code}, message is ${err.message}}`);
        })
    } catch (e) {
      hilog.error(audioDomain, audioPrefix, `resume failed, undefined resume error`);
    }
  }

  /**
   * Seek player media
   * @param ms
   */
  public seek(ms: number) {
    if (!this.player) {
      return;
    }

    this.updateProgress(ms)
    this.player.seek(ms);
  }

  /**
   * Play next music.
   */
  public async playNext() {
    hilog.info(audioDomain, audioPrefix,
      'playNext Index:' + this.musicIndex + ', length-1:' + (this.songList.length - 1));
    if (!this.player) {
      hilog.error(audioDomain, audioPrefix, 'player is undefined playNext');
      return;
    }
    await this.stop();
    this.isFirst = false;
    if (this.musicIndex + 1 < this.songList.length) {
      this.startByIndex(this.musicIndex + 1);
    } else {
      this.startByIndex(0);
    }
  }

  /**
   * Play previous music.
   */
  public async playPrevious() {
    hilog.info(audioDomain, audioPrefix,
      'playPrevious Index:' + this.musicIndex + ', length-1:' + (this.songList.length - 1));
    if (!this.player) {
      hilog.error(audioDomain, audioPrefix, 'audioRenderer is undefined playPrevious');
      return;
    }
    await this.stop();
    this.isFirst = false;
    if (this.musicIndex - 1 >= 0) {
      this.startByIndex(this.musicIndex - 1);
    } else {
      this.startByIndex(this.songList.length - 1);
    }
  }

  /**
   * Start music by index.
   *
   * @param musicIndex
   */
  public async startByIndex(musicIndex: number = this.musicIndex) {
    if (musicIndex >= this.songList.length) {
      hilog.error(audioDomain, audioPrefix, `current musicIndex ${musicIndex}`);
      return;
    }

    BackgroundUtil.startContinuousTask(this.context);
    this.updateMusicIndex(musicIndex);
    if (this.isFirst) {
      this.isFirst = false;
      await this.loadSongUrl();
    } else {
      await this.stop();
      this.updateIsPlay(false);
      await this.reset();
    }
  }

  private async reset() {
    hilog.info(audioDomain, audioPrefix, 'reset()');
    if (this.player) {
      this.isFirst = true;
      this.startByIndex(this.musicIndex);
    }
  }

  /**
   * load song file music.
   */
  private async loadSongUrl() {
    if (!this.player || !this.context) {
      return;
    }

    try {
      hilog.info(audioDomain, audioPrefix, `song to start: ${this.songList[this.musicIndex].src}`);
      hilog.info(audioDomain, audioPrefix, `song to start state: ${this.player.state}`);
      await this.player.reset();
      this.player.fdSrc = await MediaTools.getAVFileDescriptor(this.context, this.songList[this.musicIndex].src);
      hilog.info(audioDomain, audioPrefix, 'song loaded');
    } catch (e) {
      hilog.error(audioDomain, audioPrefix, `song load failed, undefined error load`);
    }
  }

  /**
   * Stop music
   */
  public async stop() {
    if (this.player) {
      try {
        await this.player.stop().catch((err: BusinessError) => {
          hilog.error(audioDomain, audioPrefix, `stop failed,code is ${err.code},message is ${err.message}}`);
        })
        this.curMs = 0;
        this.updateIsPlay(false);
        AppStorage.setOrCreate('currentTime', '00:00');
        AppStorage.setOrCreate('progress', 0);
        hilog.info(audioDomain, audioPrefix, 'stop success');
      } catch (e) {
        hilog.error(audioDomain, audioPrefix, `stop failed,audioRenderer is undefined error stop`);
      }
    }
  }

  public getFirst() {
    return this.isFirst;
  }

  private updateMusicIndex(musicIndex: number) {
    hilog.info(audioDomain, audioPrefix, 'updateMusicIndex ===> ' + musicIndex);
    AppStorage.setOrCreate('selectIndex', musicIndex);
    if (this.musicIndex !== musicIndex) {
      this.musicIndex = musicIndex;
    }
    if (!this.avSessionController) {
      return;
    }
    hilog.info(audioDomain, audioPrefix, 'this.session !== undefined ');
  }

  /**
   * release audioRenderer
   */
  public async release() {
    if (this.player && this.context) {
      try {
        await this.player.release().catch((err: BusinessError) => {
          hilog.error(audioDomain, audioPrefix, `release failed,code is ${err.code},message is ${err.message}}`);
        })
        this.avSessionController?.unregisterSessionListener();
        BackgroundUtil.stopContinuousTask(this.context);
        hilog.info(audioDomain, audioPrefix, 'release success');
      } catch (e) {
        hilog.error(audioDomain, audioPrefix, `release failed, player is undefined`);
      }
    }
  }
}