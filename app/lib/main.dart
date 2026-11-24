import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'features/auth/application/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        // Lets the network layer end a dead session without importing auth.
        unauthorizedHandlerProvider.overrideWith(
          (ref) => () => ref.read(authControllerProvider.notifier).expire(),
        ),
      ],
      child: const App(),
    ),
  );
}
