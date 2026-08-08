@Component
export struct StatusBadge {
  @Prop label: string = '';
  @Prop exported: boolean = false;

  build() {
    Row({ space: 5 }) {
      Text(this.exported ? '✓' : '•')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.exported ? $r('app.color.status_exported') : $r('app.color.status_draft'))
      Text(this.label)
        .fontSize($r('app.float.font_minimum'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.exported ? $r('app.color.status_exported') : $r('app.color.status_draft'))
    }
    .height(32)
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius($r('app.float.radius_control'))
    .accessibilityText(this.label)
  }
}
