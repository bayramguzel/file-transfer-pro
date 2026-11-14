import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filetransfer/core/services/rating_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RatingService Tests', () {
    test('Initial state: has not rated and should not prompt immediately',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ratingService = RatingService(prefs);

      expect(ratingService.hasRated, false);
      expect(ratingService.neverAskAgain, false);
      expect(ratingService.shouldPromptForRating(), false);
    });

    test('Prompts after minimum launches reached', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ratingService = RatingService(prefs);

      await ratingService.recordLaunch();
      await ratingService.recordLaunch();
      await ratingService.recordLaunch();

      expect(ratingService.launchCount, 3);
      expect(ratingService.shouldPromptForRating(), true);
    });

    test('Prompts after minimum transfers reached', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ratingService = RatingService(prefs);

      await ratingService.recordTransfer();
      await ratingService.recordTransfer();

      expect(ratingService.transferCount, 2);
      expect(ratingService.shouldPromptForRating(), true);
    });

    test('Never prompts again after markAsRated', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ratingService = RatingService(prefs);

      await ratingService.recordTransfer();
      await ratingService.recordTransfer();
      expect(ratingService.shouldPromptForRating(), true);

      await ratingService.markAsRated(stars: 5);
      expect(ratingService.hasRated, true);
      expect(ratingService.starsGiven, 5);
      expect(ratingService.shouldPromptForRating(), false);
    });

    test('Delays prompt after remindLater', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ratingService = RatingService(prefs);

      await ratingService.recordTransfer();
      await ratingService.recordTransfer();
      expect(ratingService.shouldPromptForRating(), true);

      await ratingService.remindLater();
      // Should not prompt immediately after remindLater
      expect(ratingService.shouldPromptForRating(), false);
    });

    test('Never prompts again after setNeverAskAgain', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ratingService = RatingService(prefs);

      await ratingService.recordTransfer();
      await ratingService.recordTransfer();
      expect(ratingService.shouldPromptForRating(), true);

      await ratingService.setNeverAskAgain();
      expect(ratingService.neverAskAgain, true);
      expect(ratingService.shouldPromptForRating(), false);
    });
  });
}

