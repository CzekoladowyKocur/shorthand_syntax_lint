import 'package:shorthand_syntax_lint/src/fixes/convert_to_shorthand.dart';
import 'package:test/test.dart';

import 'resolve.dart';

class FixHostTest extends SnippetResolutionTest {
  Future<void> assertHasEdit(
    String before,
    String longhand,
    String after,
  ) async {
    await resolveSnippet(before);
    var edit = shorthandEdit(expression(longhand));
    expect(edit, isNotNull, reason: "Expected an edit for '$longhand'");
    var applied = before.replaceRange(
      edit!.range.offset,
      edit.range.end,
      edit.replacement,
    );
    expect(applied, after);
  }

  Future<void> assertNoEdit(String content, String longhand) async {
    await resolveSnippet(content);
    expect(
      shorthandEdit(expression(longhand)),
      isNull,
      reason: "Expected no edit for '$longhand'",
    );
  }
}
