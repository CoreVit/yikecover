@Component
export struct PageTitleBlock {
  @Prop title: string = '';
  @Prop subtitle: string = '';

  build() {
    Column({ space: 3 }) {
      Text(this.title)
        .fontSize($r('app.float.font_page_title'))
        .lineHeight(32)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize($r('app.float.font_secondary'))
          .lineHeight(20)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}
