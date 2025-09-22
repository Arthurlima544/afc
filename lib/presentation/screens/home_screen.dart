import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      const Spacer(),
      const Center(child: CircularProgressIndicator(size: 25)),
      OutlineButton(
        onPressed: () {
          GoRouter.of(context).push('/login');
        },
        child: const Text('Login Screen'),
      ),
      const Spacer(),
    ],
  );
}
