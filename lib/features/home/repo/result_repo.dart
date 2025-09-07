import 'package:smart_trip_planner_flutter/services/data/firebase_ai_repo.dart';
import 'package:smart_trip_planner_flutter/services/domain/genai_repo.dart';

class ResultRepo {
  final GenAiRepo _genAiRepo = FirebaseAiRepo();

  Future<ResultResponse> refinePrompt(String tripString, String prompt) =>
      _genAiRepo.refinePrompt(tripString, prompt);

  Future<ResultResponse> searchPrompt(String prompt) => _genAiRepo.searchPrompt(prompt);

  Stream<StreamResponse> searchPromptStream(String prompt) =>
      _genAiRepo.searchPromptStream(prompt);
}
