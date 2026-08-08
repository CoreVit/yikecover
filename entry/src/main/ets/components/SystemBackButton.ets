@Component
export struct SystemBackButton {
  onBack: () => void = (): void => {
  };

  build() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.chevron_backward'))
        .fontSize(22)
        .fontColor([$r('app.color.text_primary')])
    }
    .width(48)
    .height(48)
    .padding(0)
    .backgroundColor($r('app.color.control_background'))
    .borderRadius(12)
    .accessibilityText('返回')
    .onClick(() => {
      this.onBack();
    })
  }
}
