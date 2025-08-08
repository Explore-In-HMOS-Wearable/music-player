import { SongData } from '../viewmodel/SongData';

export class DataModel {
  public static readonly SONG_LIST: SongData[] = [
    {
      id: 1,
      title: 'Ambush in Rattle snake Gulch',
      artist: 'N/A',
      artwork: $r('app.media.ic_dream_it'),
      src: 'AmbushinRattlesnakeGulch.mp3'
    },
    {
      id: 2,
      title: 'Awkward Apocalyptic Pickup',
      artist: 'N/A',
      artwork: $r('app.media.ic_world'),
      src: 'AwkwardApocalypticPickup.mp3'
    },
    {
      id: 3,
      title: 'Improv for Evil',
      artist: 'N/A',
      artwork: $r('app.media.ic_power'),
      src: 'ImprovforEvil.mp3'
    },
    {
      id: 4,
      title: 'Sun Up Gunned Down',
      artist: 'N/A',
      artwork: $r('app.media.ic_boisterous'),
      src: 'SunUpGunnedDown.mp3'
    }
  ];
}