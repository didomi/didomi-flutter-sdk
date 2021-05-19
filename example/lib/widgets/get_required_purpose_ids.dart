import 'dart:async';

import 'package:didomi_sdk/didomi_sdk.dart';
import 'package:didomi_sdk_example/widgets/base_sample_widget_state.dart';
import 'package:flutter/material.dart';

/// Widget to call DidomiSdk.getRequiredPurposeIds
class GetRequiredPurposeIds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GetRequiredPurposeIds();
}

class _GetRequiredPurposeIds
    extends BaseSampleWidgetState<GetRequiredPurposeIds> {
  @override
  String getButtonName() => 'GetRequiredPurposeIds';

  @override
  String getActionId() => 'getRequiredPurposeIds';

  @override
  Future<String> callDidomiPlugin() async {
    final List<String> result = await DidomiSdk.requiredPurposeIds;
    if (result.isEmpty) {
      return "Required Purposes list is empty";
    } else {
      return "Required Purposes: ${result.join(",")}";
    }
  }
}