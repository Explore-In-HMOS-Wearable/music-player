import { DataModel } from 'entry/ets/model/DataModel';
import { SongData } from 'entry/ets/viewmodel/SongData';

export default class WearableViewModel {
  public getSongList(): SongData[] {
    return DataModel.SONG_LIST;
  }
}