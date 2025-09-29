import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../blocs/home/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const Gap(20),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) =>
                const SummaryWidget(),
          ),
          const Gap(20),
          const LastTransactionsWidget(),
          const MonthLimitWidget(),
          const Gap(20),
          const StatsWidget(),
        ],
      ).withPadding(all: 20),
    ),
  );
}

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Estatísticas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              //TODO Navigate to all transactions page
            },
            child: const Text(
              'Ver Todas',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
      const Gap(10),
      const LineChartSample7(line1Color: Colors.red, line2Color: Colors.green),
    ],
  );
}

class LineChartSample7 extends StatelessWidget {
  const LineChartSample7({
    required this.line1Color,
    required this.line2Color,
    super.key,
    // required  this.betweenColor,
  });

  final Color line1Color;
  final Color line2Color;
  //  Color get betweenColor => contentColorRed.withValues(alpha: 0.5);

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const TextStyle style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Fev';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Abr';
        break;
      case 4:
        text = 'Mai';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Ago';
        break;
      case 8:
        text = 'Set';
        break;
      case 9:
        text = 'Out';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dez';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const TextStyle style = TextStyle(fontSize: 10);

    String text;
    if (value >= 1000) {
      // format like 1k, 1.5k etc
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2,
    child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 18, top: 10, bottom: 4),
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: const <FlSpot>[
                FlSpot(0, 400),
                FlSpot(1, 500),
                FlSpot(2, 1100),
                FlSpot(3, 600),
                FlSpot(4, 700),
                FlSpot(5, 500),
              ],
              color: line1Color,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: const <FlSpot>[
                FlSpot(0, 1500),
                FlSpot(1, 1600),
                FlSpot(2, 1400),
                FlSpot(3, 1550),
                FlSpot(4, 1600),
                FlSpot(5, 1400),
              ],
              color: line2Color,
              dotData: const FlDotData(show: false),
            ),
          ],
          betweenBarsData: <BetweenBarsData>[
            // BetweenBarsData(fromIndex: 0, toIndex: 1, color: betweenColor),
          ],
          minY: 0,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: leftTitleWidgets,
                interval: 500,
                reservedSize: 36,
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            checkToShowHorizontalLine: (double value) =>
                value == 1 || value == 6 || value == 4 || value == 5,
          ),
        ),
      ),
    ),
  );
}

class MonthLimitWidget extends StatelessWidget {
  const MonthLimitWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Limites do mês',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              //TODO Navigate to all transactions page
            },
            child: const Text(
              'Ver Todas',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
      const Gap(10),
      const SizedBox(
        height: 150,
        child: Column(
          children: <Widget>[
            MonthLimit(
              category: 'Transporte',
              amount: 900,
              icon: Icons.local_taxi,
              totalLimit: 1000,
            ),
            Gap(10),
            MonthLimit(
              category: 'Compras',
              amount: 200,
              icon: Icons.shop,
              totalLimit: 1000,
            ),
          ],
        ),
      ),
    ],
  );
}

class MonthLimit extends StatelessWidget {
  const MonthLimit({
    required this.category,
    required this.amount,
    required this.icon,
    required this.totalLimit,
    super.key,
  });

  final String category;
  final double amount;
  final double totalLimit;
  final IconData icon;

  double get percent => amount / totalLimit;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      IconButton(
        variance: const ButtonStyle.primary(),
        onPressed: () => print('percent: $percent'),
        enabled: true,
        shape: ButtonShape.circle,
        icon: Icon(icon, size: 24, color: Colors.white),
      ),
      const Gap(15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(category, style: const TextStyle(fontSize: 18)),
          const Gap(5),
          Text(
            '${convertToCurrencyFormated(amount)} de ${convertToCurrencyFormated(totalLimit)}',
            style: const TextStyle(fontSize: 14),
          ),
          const Gap(5),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: percent > 0.5 ? Colors.red : Colors.green,
              value: percent,
              minHeight: 3,
            ),
          ),
        ],
      ),
      const Gap(5),
    ],
  );
}

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    children: <Widget>[
      HomeCard(
        title: 'Saldo',
        totalAmount: 1000,
        icon: Icons.savings_outlined,
        backgroundColor: Color(0xFFDCE1FF),
        iconColor: Colors.black,
      ),
      Gap(20),
      Row(
        children: <Widget>[
          Expanded(
            child: HomeCard(
              title: 'Entradas',
              totalAmount: 5000,
              icon: Icons.attach_money,
              backgroundColor: Color(0xFFBDECB5),
              iconColor: Colors.black,
            ),
          ),
          Gap(5),
          Expanded(
            child: HomeCard(
              title: 'Despesas',
              totalAmount: 4000,
              icon: Icons.currency_exchange,
              backgroundColor: Color(0xFFFFDAD6),
              iconColor: Colors.black,
            ),
          ),
        ],
      ),
    ],
  );
}

class LastTransactionsWidget extends StatelessWidget {
  const LastTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Transações Recentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              //TODO Navigate to all transactions page
            },
            child: const Text(
              'Ver Todas',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
      const Gap(10),
      const SizedBox(
        height: 150,
        child: Column(
          children: <Widget>[
            LastTransactions(
              category: 'Compras',
              amount: -5000,
              icon: Icons.attach_money,
            ),
            Gap(10),
            LastTransactions(
              category: 'Freela',
              amount: 5000,
              icon: Icons.attach_money,
            ),
          ],
        ),
      ),
    ],
  );
}

class LastTransactions extends StatelessWidget {
  const LastTransactions({
    required this.category,
    required this.amount,
    required this.icon,
    super.key,
  });

  final String category;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      IconButton(
        variance: const ButtonStyle.primary(),
        enabled: true,
        shape: ButtonShape.circle,
        icon: Icon(icon, size: 24, color: Colors.white),
      ),
      const Gap(15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(category, style: const TextStyle(fontSize: 18)),
            Text(
              convertToCurrencyFormated(amount),
              style: TextStyle(
                fontSize: 14,
                color: amount < 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    required this.title,
    required this.totalAmount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    super.key,
  });

  final String title;
  final double totalAmount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => Card(
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth;

        const double baseCardWidth = 180.0;

        final double scaleFactor = (cardWidth / baseCardWidth).clamp(0.75, 1.2);

        final double iconSize = 24.0 * scaleFactor;
        final double gapSize = 15.0 * scaleFactor;
        final double largeFontSize = 18.0 * scaleFactor;
        final double smallFontSize = 14.0 * scaleFactor;

        return Row(
          children: <Widget>[
            IconButton(
              variance: const ButtonStyle.primary().withBackgroundColor(
                color: backgroundColor,
              ),
              enabled: true,
              shape: ButtonShape.circle,
              icon: Icon(icon, size: iconSize, color: iconColor),
            ),
            Gap(gapSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    convertToCurrencyFormated(totalAmount),
                    style: TextStyle(
                      fontSize: largeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
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

String convertToCurrencyFormated(double amount) {
  final NumberFormat format = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  return format.format(amount);
}
