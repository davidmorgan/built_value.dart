import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';

Future<AnalysisContext> createDriver({required String workspace}) async {
  final contextBuilder = ContextBuilder();

  final result = contextBuilder.createContext(
      contextRoot:
          ContextLocator().locateRoots(includedPaths: [workspace]).first);

  return result;
}
