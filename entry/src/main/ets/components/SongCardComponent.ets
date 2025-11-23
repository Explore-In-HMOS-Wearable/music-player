export interface SongImage {
  src: PixelMap | ResourceStr | DrawableDescriptor;
  width?: Length;
  height?: Length;
  borderRadius: Length;
}

export interface SongTitle {
  text: string;
  margin?: Margin;
  fontSize: Length;
  textColor: ResourceColor;
}

export interface SongDesc {
  text: string;
  margin?: Margin;
  fontSize: Length;
  textColor: ResourceColor;
}

@Component
export struct SongCardComponent {
  wearableStyle: boolean = false;
  image?: SongImage;
  title?: SongTitle;
  desc?: SongDesc;

  build() {
    if (this.wearableStyle) {
      Row() {
        Image(this.image?.src)
          .aspectRatio(1)
          .width(this.image?.width)
          .height(this.image?.height)
          .borderRadius(this.image?.borderRadius)
        Column() {
          Text(this.title?.text)
            .fontSize(this.title?.fontSize)
            .fontColor(this.title?.textColor)
          Text(this.desc?.text)
            .fontSize(this.desc?.fontSize)
            .fontColor(this.desc?.textColor)
        }
        .margin({ left: 4, right: 4 })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
    } else {
      Column() {
        Image(this.image?.src)
          .width(this.image?.width)
          .borderRadius(this.image?.borderRadius)
        Text(this.title?.text)
          .margin(this.title?.margin)
          .fontSize(this.title?.fontSize)
          .fontColor(this.title?.textColor)
        Text(this.desc?.text)
          .margin(this.desc?.margin)
          .fontSize(this.desc?.fontSize)
          .fontColor(this.desc?.textColor)
      }
    }
  }
}

