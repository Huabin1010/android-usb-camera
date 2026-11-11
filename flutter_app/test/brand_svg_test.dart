import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the brand svg', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: _AboutProbe()),
      ),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _AboutProbe extends StatelessWidget {
  const _AboutProbe();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/brand/ic_launcher.svg', width: 96, height: 96);
  }
}
