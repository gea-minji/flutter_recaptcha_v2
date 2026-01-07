import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/colors.gen.dart';
import '../../../generated/fonts.gen.dart';
import '../../../src/common/extensions/build_context_x.dart';
import 'bottom_sheet/bottom_sheet_popup.dart';

class RecaptchaV2Button extends StatefulWidget {
  final bool? isErrorShowing;
  final Function(bool verified) onVerified;

  final String apiKey;
  final String apiSecret;
  final String pluginURL;

  const RecaptchaV2Button({
    super.key,
    this.isErrorShowing = false,
    required this.onVerified,
    required this.apiKey,
    required this.apiSecret,
    required this.pluginURL,
  });

  @override
  State<RecaptchaV2Button> createState() => _RecaptchaV2ButtonState();
}

class _RecaptchaV2ButtonState extends State<RecaptchaV2Button> {
  bool isVerified = false;

  _onUpdateVerifyState(bool isSuccess) {
    setState(() {
      isVerified = isSuccess;
      widget.onVerified(isVerified);
      if (kDebugMode) {
        if (isVerified) {
          print("You've been verified successfully.");
        } else {
          print("Failed to verify.");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 320.0,
            ),
            padding: EdgeInsets.only(left: 4, top: 4, right: 12, bottom: 4),
            decoration: BoxDecoration(
              color: ColorName.buttonBackground,
              border: Border.all(
                color: ColorName.borderGrey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(2.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isVerified
                          ? null
                          : () => BottomSheetPopup.showRecaptchaV2(
                                context,
                                widget.apiKey,
                                widget.apiSecret,
                                widget.pluginURL,
                                onVerify: _onUpdateVerifyState,
                                onCanceled: () {},
                              ),
                      icon: isVerified
                          ? RCAssets.icons.icTickGreen.svg()
                          : RCAssets.icons.icCbEmpty.svg(),
                    ),
                    Text(
                      "I'm not a robot",
                      style: context.textTheme.regular.copyWith(
                        color: ColorName.black,
                        fontFamily: FontFamily.roboto,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 62.0,
                  width: 66.0,
                  child: RCAssets.images.icPcTc.image(fit: BoxFit.fill),
                )
              ],
            ),
          ),
          SizedBox(height: 4),
          widget.isErrorShowing == true && isVerified == false
              ? Text(
                  'Please verify that you are not a robot.',
                  style: context.textTheme.regular.copyWith(
                    color: ColorName.red,
                    fontFamily: FontFamily.roboto,
                    fontSize: 14,
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
