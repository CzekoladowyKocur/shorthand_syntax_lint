import 'dart:io';

const Set<String> _pluginCodes = {
  'PREFER_CONSTRUCTOR_SHORTHANDS',
  'PREFER_ENUM_SHORTHANDS',
  'PREFER_RETURN_SHORTHANDS',
  'PREFER_STATIC_MEMBER_SHORTHANDS',
  'PREFER_UNNAMED_CONSTRUCTOR_SHORTHANDS',
};

Future<void> main() async {
  final scriptPath = Platform.script.toFilePath();
  final toolDir = File(scriptPath).parent.path;
  final repoRoot = Directory(toolDir).parent.path;
  final exampleDir = '$repoRoot${Platform.pathSeparator}example';
  final expectedFile = File(
    '$toolDir${Platform.pathSeparator}expected_diagnostics.txt',
  );

  if (!expectedFile.existsSync()) {
    stderr.writeln('Missing expected file: ${expectedFile.path}');
    exit(1);
  }

  final result = await Process.run(Platform.resolvedExecutable, [
    'analyze',
    '--format=machine',
    '.',
  ], workingDirectory: exampleDir);
  final analyzeStdout = result.stdout as String;
  final analyzeStderr = result.stderr as String;

  if (result.exitCode != 0 && result.exitCode != 1) {
    stderr
      ..writeln('dart analyze exited with unexpected code ${result.exitCode}')
      ..writeln(analyzeStdout)
      ..writeln(analyzeStderr);
    exit(1);
  }

  final actual = <String>[];
  for (final line in analyzeStdout.split('\n')) {
    final fields = line.split('|');
    if (fields.length < 8) {
      continue;
    }
    final code = fields[2];
    if (!_pluginCodes.contains(code)) {
      continue;
    }
    final relativePath = _relativeToExample(fields[3], exampleDir);
    actual.add('$code|$relativePath|${fields[4]}|${fields[5]}|${fields[6]}');
  }
  actual.sort();

  if (actual.isEmpty) {
    stderr
      ..writeln('No plugin diagnostics reported; the plugin did not load.')
      ..writeln(analyzeStdout)
      ..writeln(analyzeStderr);
    exit(1);
  }

  final expected =
      expectedFile
          .readAsLinesSync()
          .where((line) => line.trim().isNotEmpty)
          .toList()
        ..sort();

  if (_sameLines(expected, actual)) {
    stdout.writeln('Dogfood check passed: ${actual.length} diagnostics match.');
    return;
  }

  stderr
    ..writeln('Diagnostic mismatch between expected and actual.')
    ..writeln('--- expected (tool/expected_diagnostics.txt)')
    ..writeln('+++ actual (dart analyze --format=machine in example/)');
  final expectedSet = expected.toSet();
  final actualSet = actual.toSet();
  for (final line in expected) {
    stderr.writeln(actualSet.contains(line) ? ' $line' : '-$line');
  }
  for (final line in actual) {
    if (!expectedSet.contains(line)) {
      stderr.writeln('+$line');
    }
  }
  exit(1);
}

String _relativeToExample(String absolutePath, String exampleDir) {
  final prefix = '$exampleDir${Platform.pathSeparator}';
  final relative = absolutePath.startsWith(prefix)
      ? absolutePath.substring(prefix.length)
      : absolutePath;
  return relative.replaceAll(Platform.pathSeparator, '/');
}

bool _sameLines(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
