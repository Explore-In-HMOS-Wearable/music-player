import { MediaController} from 'entry/ets/utils/MediaController';
import { SongData } from 'entry/ets/viewmodel/SongData';
import { SizeConstants } from 'entry/ets/constants/SizeConstants';
import { AppFontSize} from 'entry/ets/constants/AppFontSize';
import { AppFontWeight} from 'entry/ets/constants/AppFontWeight';
import { PlayPauseButton } from './PlayPauseButton';

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .objectFit(ImageFit.Contain)
}

@Component
export struct PlaybackView {
  @StorageLink('selectIndex') selectIndex: number = 0;
  @StorageLink('songList') songList: SongData[] = [];
  @StorageLink('currentTime') currentTime: string = '00:00';
  @StorageLink('totalTime') totalTime: string = '00:00';

  build() {
    Stack() {
      Column() {
        Column() {
          Text(this.currentTime)
            .fontColor($r('app.color.deep_teal'))
            .fontSize(AppFontSize.SMALL)
          Text(this.songList[this.selectIndex].title)
            .fontSize(AppFontSize.MIDDLE)
            .fontWeight(AppFontWeight.BOLD)
            .fontColor($r('app.color.deep_teal'))
            .margin({ top: $r('app.float.margin_4') })
          Text(this.songList[this.selectIndex].artist)
            .fontSize(AppFontSize.SMALL)
            .fontColor($r('app.color.deep_teal'))
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: $r('app.float.margin_10') })

        Row() {
          Image($r('app.media.ic_prev'))
            .controlImageBuilder()
            .width($r('app.float.control_width'))
            .onClick(() => {
              MediaController.getInstance().playPrevious();
            })

          PlayPauseButton()

          Image($r('app.media.ic_next'))
            .controlImageBuilder()
            .width($r('app.float.control_width'))
            .onClick(() => {
              MediaController.getInstance().playNext();
            })
        }
        .layoutWeight(1)
        .padding({
          left: $r('app.float.margin_4'),
          right: $r('app.float.margin_4'),
          bottom: $r('app.float.margin_8'),
        })
        .width(SizeConstants.FULL_WIDTH_PERCENT)
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
    }
    .width(SizeConstants.FULL_WIDTH_PERCENT)
    .height(SizeConstants.FULL_HEIGHT_PERCENT)
  }
}