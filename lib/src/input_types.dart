/// All supported input types for [QuestionStep].
///
/// Each value maps to a specific input widget with appropriate
/// keyboard, validation, and UI behavior.
enum InputType {
  /// Email address input with email keyboard and regex validation.
  email,

  /// Person name input with letter-only filter and word capitalization.
  name,

  /// Secure password input with obscured text.
  password,

  /// Date picker using native platform date selector.
  date,

  /// Combined date and time picker.
  dateTime,

  /// General text input, supports multi-line via [QuestionStep.numberOfLines].
  text,

  /// Time picker using native platform time selector.
  time,

  /// File upload with optional extension filters via [QuestionStep.filter].
  file,

  /// Numeric input with number keyboard, supports [QuestionStep.mask] formatting.
  number,

  /// Emoji-based satisfaction rating (1-5 scale).
  smile,

  /// Single selection from a list of [Options].
  singleChoice,

  /// Multiple selection from a list of [Options].
  multipleChoice,

  /// Multi-digit one-time password entry, configurable via [QuestionStep.count].
  otp,

  /// Traditional dropdown menu for single selection.
  dropdown,

  /// Dynamic list of key-value pair inputs, configurable via [QuestionStep.maxCount].
  dynamicKeyValue,

  /// Rich text / HTML editor.
  htmlEditor,

  /// Google Maps location picker.
  mapLocation,

  /// Circular profile image upload (returns base64).
  avatar,

  /// Rectangular banner image upload (returns base64).
  banner,

  /// Range slider with configurable min, max, and step values.
  slider,

  /// Star rating input (1 to N stars), configurable via [QuestionStep.ratingCount].
  rating,

  /// Net Promoter Score (0-10 scale) with color-coded buttons.
  nps,

  /// Checkbox with agreement text for terms, GDPR, or legal consent.
  consent,

  /// Canvas-based signature drawing pad (returns base64 PNG).
  signature,

  /// Drag-to-reorder list for priority ranking of [Options].
  ranking,

  /// Phone number input with country code dropdown picker.
  phone,

  /// Currency/money input with symbol prefix and decimal formatting.
  currency,

  /// Boolean Yes/No toggle selection.
  boolean,

  /// Select from a grid of images with labels.
  imageChoice,

  /// Hidden field that stores data without any UI. Use with [FormStep.defaultValue]
  /// or [QuestionStep.calculateExpression] to set computed values.
  hidden,

  /// Auto-calculated field derived from other step results.
  /// Use [QuestionStep.calculateExpression] to define the formula.
  calculate,

  /// Barcode/QR code scanner using device camera.
  barcode,

  /// Audio recording input. Records and returns file path.
  audio,

  /// Trace a path/line on a map. Returns list of lat/lng coordinates.
  geotrace,

  /// Draw a polygon/shape on a map. Returns list of lat/lng coordinates forming a closed area.
  geoshape,
}
