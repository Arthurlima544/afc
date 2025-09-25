import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: const Column(
      children: <Widget>[
        Gap(20),
        HomeCard(),
        Gap(20),
        Row(
          children: <Widget>[
            Expanded(child: HomeCard()),
            Gap(5),
            Expanded(child: HomeCard()),
          ],
        ),
      ],
    ).withPadding(all: 20),
  );
}

class HomeCard extends StatelessWidget {
  const HomeCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth;

        // Define a "base" or "ideal" width for the card.
        // At this width, our content will be at its normal size.
        const double baseCardWidth = 180.0;

        // Calculate a scale factor based on the available width.
        // We clamp it to prevent the content from becoming too small or too large.
        final double scaleFactor = (cardWidth / baseCardWidth).clamp(0.75, 1.2);

        // Apply the scale factor to all elements.
        final double iconSize = 24.0 * scaleFactor;
        final double gapSize = 15.0 * scaleFactor;
        final double largeFontSize = 18.0 * scaleFactor;
        final double smallFontSize = 14.0 * scaleFactor;

        return Row(
          children: <Widget>[
            IconButton(
              variance: const ButtonStyle.primary(),

              enabled: true,

              shape: ButtonShape.circle,

              icon: Icon(Icons.savings_outlined, size: iconSize),
            ),
            Gap(gapSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'R\$ 3.000,00',
                    style: TextStyle(
                      fontSize: largeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Saldo',
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: Colors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      // user icon
      Icon(Icons.person, size: 40),
      Gap(10),
      Text('Welcome, User!', style: TextStyle(fontSize: 20)),
      Gap(10),
      Icon(Icons.notifications, size: 30),
      Gap(10),
      Icon(Icons.settings, size: 30),
      Gap(10),
    ],
  );
}
