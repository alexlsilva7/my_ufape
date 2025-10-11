import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/ui/gen/assets.gen.dart';
import 'package:my_ufape/ui/splash/splash_view_model.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  SplashViewModel viewModel = injector.get<SplashViewModel>();

  @override
  void initState() {
    viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
              child: Assets.images.myUfapeLogo.image(
                width: 150,
                height: 150,
              ),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
