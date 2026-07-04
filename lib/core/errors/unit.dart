/// A type with exactly one value — the success payload for `Result<Unit>`,
/// used by operations that succeed or fail but return no data.
class Unit {
  const Unit._();
  static const value = Unit._();
}
