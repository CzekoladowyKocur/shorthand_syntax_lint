## 0.2.0

- Flag longhand heads of selector chains (`int.parse(s).abs()`), including
  in equality and null-assert positions.

## 0.1.0

- Initial release.
- Adds `prefer_enum_shorthands`, `prefer_constructor_shorthands`, and
  `prefer_static_member_shorthands`, enabled by default.
- Adds the opt-in `prefer_unnamed_constructor_shorthands` and
  `prefer_return_shorthands`.
- Adds quick fixes converting longhand to shorthand, available in IDEs.
- Requires `analysis_server_plugin` 0.3.20 or later; versions 0.3.16 through
  0.3.19 hang `dart analyze` on stable SDKs.
