import { SongData } from 'entry/ets/viewmodel/SongData';
import { SongCardComponent } from 'entry/ets/components/SongCardComponent';
import { SizeConstants } from 'entry/ets/constants/SizeConstants';
import { AppFontSize} from 'entry/ets/constants/AppFontSize';
import { ImageConstants} from 'entry/ets/constants/ImageConstants';
import { SongDataSource } from '../viewmodel/SongDataSource';
import {
  UIContext,
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  ComponentContent,
  LengthMetrics
} from '@kit.ArkUI';

export type CardClickCallback = (songIndex: number) => void;

@Builder
function buildText() {
  Column() {
    Text('Song List')
      .fontSize(AppFontSize.LARGE)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.deep_teal'))
  }.margin(0)
}

@Component
export struct SongListView {
  @StorageLink('selectIndex') selectIndex: number = 0;
  @StorageLink('songList') songList: SongData[] = [];
  onCardClicked: CardClickCallback = () => {
  };
  context: UIContext = this.getUIContext();
  tabBar1: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildText));

  build() {
    ArcList({ initialIndex: 0, header: this.tabBar1 }) {
      LazyForEach(new SongDataSource(this.songList), (item: SongData, index: number) => {
        ArcListItem() {
          SongCardComponent({
            wearableStyle: true,
            image: {
              src: item.artwork,
              height: ImageConstants.SONG_IMAGE_SIZE,
              borderRadius: $r('app.float.margin_12')
            },
            title: {
              text: item.title,
              fontSize: AppFontSize.MIDDLE,
              textColor: $r('app.color.white')
            },
            desc: {
              text: item.artist,
              fontSize: AppFontSize.SMALLER,
              textColor: $r('app.color.geyser')
            }
          })
        }
        .width(SizeConstants.WATCH_LIST_WIDTH_PX)
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius($r('app.float.margin_16'))
        .padding($r('app.float.margin_4'))
        .align(Alignment.Center)
        .onClick(() => {
          this.onCardClicked(index)
        })
      }, (item: SongData, index?: number) => `${item.id}_${index}`)
    }
    .focusable(true)
    .focusOnTouch(true)
    .defaultFocus(true)
    .width(SizeConstants.FULL_SIZE_PX)
    .height(SizeConstants.FULL_SIZE_PX)
    .borderRadius(SizeConstants.FULL_SIZE_PX)
    .space(LengthMetrics.resource($r('app.float.margin_8')))
  }
}