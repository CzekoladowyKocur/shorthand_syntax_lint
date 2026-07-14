# shorthand_syntax_lint

An analyzer plugin with granular lint rules and quick fixes for Dart 3.10
dot-shorthand syntax. Each rule flags longhand static access (`Status.active`,
`Duration.zero`, `Point.origin()`) where the shorthand form (`.active`,
`.zero`, `.origin()`) is valid. Avoiding false positives is the design goal:
a site is flagged only when the shorthand context type resolves, by element
identity, to the same declaration as the longhand target.

## Usage

Add the plugin to the top-level `plugins:` section of the
`analysis_options.yaml` at the root of your workspace. Individual rules are
toggled, and their severity set, with the `diagnostics:` map; for example, to
also enable the two opt-in rules:

```yaml
plugins:
  shorthand_syntax_lint:
    version: ^0.1.0
    diagnostics:
      prefer_unnamed_constructor_shorthands: true
      prefer_return_shorthands: true
```

## Rules

| Rule | Flags | Default |
|---|---|---|
| `prefer_enum_shorthands` | enum constants (`Status.active`) | on |
| `prefer_constructor_shorthands` | named and factory constructors (`Point.origin()`) | on |
| `prefer_static_member_shorthands` | static fields, getters, and methods (`Duration.zero`, `int.parse(s)`) | on |
| `prefer_unnamed_constructor_shorthands` | unnamed constructors (`Point(1, 2)` to `.new(1, 2)`) | off |
| `prefer_return_shorthands` | any of the above, only in `return` statements and arrow bodies | off |

Two adoption profiles are intended. The default keeps the three kind rules on
everywhere. Alternatively, disable the kind rules and enable
`prefer_return_shorthands` to require shorthand only where the context type is
stated on the same line, in the function signature. Enabling the returns rule
alongside the kind rules reports return sites twice by design.

Diagnostics are suppressed with a namespaced ignore comment:

```dart
// ignore: shorthand_syntax_lint/prefer_enum_shorthands
```

## Known limitations

- Quick fixes work in IDEs, but `dart fix` does not run plugin-provided fixes
  ([dart-lang/sdk#61822](https://github.com/dart-lang/sdk/issues/61822)).
- Longhand followed by trailing selectors (`int.parse(s).abs()`) is not
  flagged, and neither is the supertype redirecting-factory pattern
  (`EdgeInsetsGeometry.all`). Both are deliberate false negatives.
- Analyzer plugins are only honored in the analysis options file at the
  workspace root.

## Version compatibility

Requires Dart SDK 3.11 or later. The package requires
`analysis_server_plugin` 0.3.20 or later: versions 0.3.16 through 0.3.19
cannot receive analysis roots from stable SDKs' analysis server, which makes
`dart analyze` hang.
