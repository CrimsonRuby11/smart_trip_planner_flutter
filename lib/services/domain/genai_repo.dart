import 'package:smart_trip_planner_flutter/services/data/firebase_ai_repo.dart';

abstract class GenAiRepo {
  Future<ResultResponse> refinePrompt(String tripString, String prompt);
  Future<ResultResponse> searchPrompt(String prompt);
  Stream<StreamResponse> searchPromptStream(String prompt);
}
