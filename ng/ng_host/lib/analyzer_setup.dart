import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart'
    show PhysicalResourceProvider;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/context/packages.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/performance_logger.dart'
    show PerformanceLog;
import 'package:analyzer/src/dart/analysis/performance_logger.dart';
import 'package:analyzer/src/file_system/file_system.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/source/package_map_resolver.dart';
import 'package:analyzer/src/summary/package_bundle_reader.dart';
import 'package:analyzer/src/summary/summary_sdk.dart' show SummaryBasedDartSdk;
import 'package:analyzer/src/summary2/package_bundle_format.dart';

Future<AnalysisContext> createDriver(
    {required String sdkSummaryPath, required String workspace}) async {
  final packageProvider = SummaryPackageBundleProvider();
  final resourceProvider = PhysicalResourceProvider.INSTANCE;
  final sdk =
      SummaryBasedDartSdk.forBundle(packageProvider.lookup(sdkSummaryPath));
  final sdkResolver = DartUriResolver(sdk);

  final summaryData = SummaryDataStore();
  final summaryPaths = [];
  for (final summaryPath in summaryPaths) {
    summaryData.addBundle(summaryPath, packageProvider.lookup(summaryPath));
  }
  summaryData.addBundle(null, sdk.bundle);

  final summaryResolver = InSummaryUriResolver(summaryData);

  final packages = parsePackageConfigJsonFile(resourceProvider,
      resourceProvider.getFile('$workspace/.dart_tool/package_config.json'));
  final packageMap = {
    for (var package in packages.packages) package.name: [package.libFolder]
  };
  final packageResolver = PackageMapUriResolver(resourceProvider, packageMap);

  final resolvers = [
    sdkResolver,
    summaryResolver,
    ResourceUriResolver(resourceProvider),
    packageResolver,
  ];
  final sourceFactory = SourceFactory(resolvers);
  final logger = PerformanceLog(null);
  final scheduler = AnalysisDriverScheduler(logger);
  /*final result = AnalysisDriver(
      scheduler: scheduler,
      logger: logger,
      resourceProvider: resourceProvider,
      byteStore: MemoryByteStore(),
      sourceFactory: sourceFactory,
      analysisOptions: AnalysisOptionsImpl(),
      externalSummaries: summaryData,
      packages: packages);*/

  final contextBuilder = ContextBuilder();

  final result = contextBuilder.createContext(
      contextRoot:
          ContextLocator().locateRoots(includedPaths: [workspace]).first);

  //result.analysisContext!.scheduler.start();
  return result;
}

class SummaryPackageBundleProvider {
  PackageBundleReader lookup(String path) {
    final bytes = io.File(path).readAsBytesSync();
    return PackageBundleReader(bytes);
  }
}
