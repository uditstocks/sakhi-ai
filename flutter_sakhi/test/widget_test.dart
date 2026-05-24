import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakhi_ai/main.dart';
import 'package:sakhi_ai/screens/home_screen.dart';
import 'package:sakhi_ai/services/sakhi_api_service.dart';

class _FakeApi extends SakhiApiService {
  _FakeApi() : super(baseUrl: 'http://test');

  @override
  Future<Map<String, dynamic>> fetchSyncStatus() async =>
      {'last_sync_ago': '2 mins ago'};
}

void main() {
  testWidgets('Sakhi AI home shows app title and mic', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(apiService: _FakeApi())),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sakhi AI'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.text('🌾'), findsWidgets);
  });
}
