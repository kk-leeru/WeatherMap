
import 'package:logger/logger.dart';

var logger = Logger();

void show_log() {
  

  logger.t("Trace log");
  logger.d("Debug log");
  logger.i("Info log: Entering App");
  logger.w("Warning log");
  logger.e("Error log", error: 'Test Error');
  logger.f("What a fatal log",
      error: 'error', stackTrace: StackTrace.fromString('stackTraceString'));
}


