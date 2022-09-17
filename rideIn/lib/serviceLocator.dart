import 'package:get_it/get_it.dart';
import 'functions.dart';

final GetIt getIt = GetIt.instance;

void setup(){
  getIt.registerLazySingleton(() => carMethods());
}