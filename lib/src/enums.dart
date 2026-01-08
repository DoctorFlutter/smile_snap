/// Defines the facial gestures that can trigger the shutter.
enum SnapTrigger {
  /// Trigger when a smile is detected (probability > 0.8)
  smile,

  /// Trigger when both eyes are closed (blink)
  doubleBlink,

  /// Trigger when the left eye is closed and right is open (wink)
  blinkLeft,

  /// Trigger when the right eye is closed and left is open (wink)
  blinkRight,
}