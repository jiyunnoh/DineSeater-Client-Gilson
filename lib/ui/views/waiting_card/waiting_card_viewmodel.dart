import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../../app/app.locator.dart';
import '../../../model/action_type.dart';
import '../../../model/waiting.dart';
import '../../../model/waiting_item.dart';
import '../../../model/waiting_item_update_request.dart';
import '../../../model/waiting_status.dart';
import '../../../services/dineseater_api_service.dart';
import '../../../services/waiting_storage_service.dart';

class WaitingCardViewModel extends BaseViewModel {
  final _waitingStorageService = locator<WaitingStorageService>();
  final _dineSeaterApiService = locator<DineseaterApiService>();

  bool isTableReady = false;
  bool isTimerEnd = false;

  late StopWatchTimer stopWatchTimer;

  WaitingCardViewModel() {
    stopWatchTimer =
        StopWatchTimer(mode: StopWatchMode.countDown, onEnded: onTimerEnd);
    stopWatchTimer.setPresetSecondTime(20);
  }

  Future<void> onTapTableReady(BuildContext context, int index) async {
    try {
      isTableReady = true;

      stopWatchTimer.onStartTimer();

      WaitingItem waitingItem = _waitingStorageService.waitings[index];
      waitingItem.status = WaitingStatus.TEXT_SENT.name;
      WaitingItemUpdateRequest waitingItemUpdateRequest =
          WaitingItemUpdateRequest();
      waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
      waitingItemUpdateRequest.action = ActionType.NOTIFY;

      setBusy(true);
      await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);
      await _waitingStorageService.updateWaiting(waitingItem);
      setBusy(false);
    } catch (e) {
      showAlertDialog(context, 'Exception Caught', 'An exception occurred: $e');
    }

    notifyListeners();
  }

  // TODO: display confirm alert dialog
  Future<void> onTapCancel(BuildContext context, int index) async {
    try {
      WaitingItem waitingItem = _waitingStorageService.waitings[index];
      waitingItem.status = WaitingStatus.MISSED.name;
      WaitingItemUpdateRequest waitingItemUpdateRequest =
          WaitingItemUpdateRequest();
      waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
      waitingItemUpdateRequest.action = ActionType.REPORT_MISSED;

      setBusy(true);
      await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);
      await _waitingStorageService.updateWaiting(waitingItem);
      setBusy(false);

      stopWatchTimer.onStopTimer();
    } catch (e) {
      showAlertDialog(context, 'Exception Caught', 'An exception occurred: $e');
    }

    notifyListeners();
  }

  // TODO: display confirm alert dialog
  Future<void> onTapConfirm(BuildContext context, int index) async {
    try {
      WaitingItem waitingItem = _waitingStorageService.waitings[index];
      waitingItem.status = WaitingStatus.ARRIVED.name;
      WaitingItemUpdateRequest waitingItemUpdateRequest =
          WaitingItemUpdateRequest();
      waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
      waitingItemUpdateRequest.action = ActionType.REPORT_ARRIVAL;

      setBusy(true);
      await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);
      await _waitingStorageService.updateWaiting(waitingItem);
      setBusy(false);

      stopWatchTimer.onStopTimer();
    } catch (e) {
      showAlertDialog(context, 'Exception Caught', 'An exception occurred: $e');
    }

    notifyListeners();
  }

  void onTimerEnd() {
    isTimerEnd = true;

    notifyListeners();
  }

  Future<void> onTapBackToList(BuildContext context, int index, Waiting waiting) async {
    try {
      WaitingItem waitingItem = _waitingStorageService.archivedWaitings[index];
      waitingItem.status = WaitingStatus.WAITING.name;
      WaitingItemUpdateRequest waitingItemUpdateRequest =
        WaitingItemUpdateRequest();
      waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
      waitingItemUpdateRequest.action = ActionType.REPORT_BACK_INITIAL_STATUS;

      setBusy(true);
      await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);
      await _waitingStorageService.updateWaiting(waitingItem);
      setBusy(false);

      stopWatchTimer.onStopTimer();
    } catch (e) {
      // TODO : differentiate the error
      showAlertDialog(context, 'Exception Caught', 'An exception occurred: $e');
    }
    print('back to list');
  }

  void onTapEditCard() {
    // TODO : can delete this I think
    print('edit card');
  }

  // TODO : move to view class
  void showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();// Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
