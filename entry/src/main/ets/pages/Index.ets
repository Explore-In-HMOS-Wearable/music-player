import { SongData } from 'entry/ets/viewmodel/SongData';
import { MediaController } from 'entry/ets/utils/MediaController';
import { SizeConstants } from 'entry/ets/constants/SizeConstants';
import { PlaybackView } from '../view/PlaybackView';
import { SongListView } from '../view/SongListView';
import WearableViewModel from '../viewmodel/WearableViewModel';

let viewModel: WearableViewModel = new WearableViewModel();

@Entry
@Component
struct Index {
  @State songs: SongData[] = [];
  private controller: SwiperController = new SwiperController()

  aboutToAppear(): void {
    this.songs = viewModel.getSongList();
    AppStorage.setOrCreate('songList', this.songs);
    MediaController.getInstance();
  }

  aboutToDisappear(): void {
    MediaController.getInstance().release();
  }

  build() {
    // Column() {
    Swiper(this.controller) {
      PlaybackView()
      SongListView({
        onCardClicked: (index) => {
          console.info(`song index: ${index}`);
          MediaController.getInstance().startByIndex(index);
          this.controller.showPrevious();
        }
      })
    }
    .size({
      width: SizeConstants.FULL_WIDTH_PERCENT,
      height: SizeConstants.FULL_HEIGHT_PERCENT
    })

    .nestedScroll(SwiperNestedScrollMode.SELF_FIRST)
    .vertical(false)
    .indicator(new DotIndicator().maxDisplayCount(2)
      .color($r('app.color.deep_aqua'))
      .selectedColor($r('app.color.deep_teal'))
    )
    .backgroundColor($r('app.color.app_background'))
  }
}