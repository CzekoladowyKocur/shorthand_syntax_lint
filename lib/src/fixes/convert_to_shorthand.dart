import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../context_type.dart';
import '../longhand.dart';

({SourceRange range, String replacement})? shorthandEdit(AstNode node) {
  if (node is! Expression) return null;
  var unit = node.thisOrAncestorOfType<CompilationUnit>();
  if (unit == null || !unit.featureSet.isEnabled(Feature.dot_shorthands)) {
    return null;
  }
  var longhand = matchLonghand(node);
  if (longhand == null) return null;
  if (!identical(shorthandContextElement(node), longhand.target)) return null;
  return (
    range: longhand.head,
    replacement: longhand.kind == LonghandKind.unnamedConstructor ? '.new' : '',
  );
}

class ConvertToShorthand extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'shorthand_syntax_lint.convert_to_shorthand',
    DartFixKindPriority.standard,
    'Convert to dot shorthand',
  );

  ConvertToShorthand({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var edit = shorthandEdit(node);
    if (edit == null) return;
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(edit.range, edit.replacement);
    });
  }
}
