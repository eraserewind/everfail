Teacup::Stylesheet.new :app do
  style :checkbox,
    bezelStyle: NSRegularSquareBezelStyle,
    buttonType: NSSwitchButton

  style :text,
    drawsBackground: false,
    bezeled: false,
    editable: false,
    selectable: false

  style :h1, extends: :text,
    font: NSFont.boldSystemFontOfSize(14.0)

end

