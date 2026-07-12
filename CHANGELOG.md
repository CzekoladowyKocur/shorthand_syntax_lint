## 0.1.0

- Initial release.
- Adds `prefer_enum_shorthands`, `prefer_constructor_shorthands`, and
  `prefer_static_member_shorthands`, enabled by default.
- Adds the opt-in `prefer_unnamed_constructor_shorthands` and
  `prefer_return_shorthands`.
- Adds quick fixes converting longhand to shorthand, available in IDEs.
- Caps `analysis_server_plugin` below 0.3.16 until a stable SDK ships the
  updated analysis server protocol.
