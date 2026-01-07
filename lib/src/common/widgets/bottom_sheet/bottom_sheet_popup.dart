import 'package:flutter/material.dart';

import '../../../../flutter_recaptcha_v2_compat.dart';
import '../../../../generated/colors.gen.dart';
import 'bottom_sheet_page_view.dart';
import 'core/bottom_sheet_page_delegate.dart';

class BottomSheetPopup {
  static void showRecaptchaV2(
    BuildContext context,
    String apiKey,
    String apiSecret,
    String pluginURL, {
    VoidCallback? onCanceled,
    Function(bool isSuccess)? onVerify,
  }) {
    BottomSheetPageView.showBottomSheet(context, providers: [], children: [
      BottomSheetPageDelegate(
        padding: EdgeInsets.zero,
        boxDecoration: const BoxDecoration(color: ColorName.background),
        onCanceled: onCanceled,
        builder: (context) {
          RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();
          return RecaptchaV2(
            apiKey: apiKey,
            apiSecret: apiSecret,
            pluginURL: pluginURL,
            controller: recaptchaV2Controller,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 24),
            onVerifiedError: (err) {
              print(err);
            },
            onVerifiedSuccessfully: (isSuccess) {
              onVerify?.call(isSuccess);
              Navigator.of(context).maybePop();
            },
          );
        },
      ),
    ]);
  }
}
