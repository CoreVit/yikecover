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
    .width(40)
    .height(40)
    .padding(0)
    .backgroundColor($r('app.color.control_background'))
    .accessibilityText('返回')
    .onClick(() => {
      this.onBack();
    })
  }
}
