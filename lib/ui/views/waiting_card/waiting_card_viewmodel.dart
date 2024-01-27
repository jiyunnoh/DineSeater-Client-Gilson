import 'dart:async';

import 'package:dineseater_client_gilson/app/app.dialogs.dart';
import 'package:dineseater_client_gilson/model/waiting_item_publish_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../../app/app.locator.dart';
import '../../../model/action_type.dart';
import '../../../model/waiting_item.dart';
import '../../../model/waiting_item_update_request.dart';
import '../../../model/waiting_status.dart';
import '../../../services/dineseater_api_service.dart';
import '../../../services/waiting_storage_service.dart';


// parent view's loading is required, due to SNS message sending threshold.
class WaitingCardViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _waitingStorageService = locator<WaitingStorageService>();
  final _dineSeaterApiService = locator<DineseaterApiService>();

  bool isTextSent = false;
  bool isTimerEnd = false;

  WaitingItem waitingItem;
  late StopWatchTimer stopWatchTimer;
  final Function toggleIsLoadingFromParent;

  final _waitingTime = int.parse(dotenv.env['WAITING_TIME_IN_SEC']!);

  String get dateCreated =>
      DateFormat('HH:mm a').format(DateTime.parse(waitingItem.dateCreated));

  String get lastModified =>
      DateFormat('HH:mm a').format(DateTime.parse(waitingItem.lastModified));

  String get formattedPhoneNumber =>
      '${waitingItem.phoneNumber.substring(2, 5)}-${waitingItem.phoneNumber.substring(5, 8)}-${waitingItem.phoneNumber.substring(8, 12)}';

  WaitingCardViewModel(this.waitingItem, this.toggleIsLoadingFromParent) {
    stopWatchTimer =
        StopWatchTimer(mode: StopWatchMode.countDown, onEnded: onTimerEnd);

    stopWatchTimer.setPresetSecondTime(_waitingTime);

    if (waitingItem.status.toUpperCase() == WaitingStatus.TEXT_SENT.name) {
      isTextSent = true;

      DateTime now = DateTime.now();
      DateTime lastModified = DateTime.parse(waitingItem.lastModified);
      int remainingTime = _waitingTime - now.difference(lastModified).inSeconds;

      if (remainingTime <= 0) {
        isTimerEnd = true;
        stopWatchTimer.clearPresetTime();
        stopWatchTimer.onStopTimer();
      } else {
        stopWatchTimer.clearPresetTime();
        stopWatchTimer.setPresetSecondTime(remainingTime);
        stopWatchTimer.onStartTimer();
      }
    } else {
      isTextSent = false;
      stopWatchTimer.onStopTimer();
    }
  }

  Future<void> showConfirmDialog(WaitingItem waitingItem,
      {bool isArchiveView = false}) async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: isArchiveView
            ? 'Back ${waitingItem.name} to list?'
            : 'Send text to ${waitingItem.name}?',
        barrierDismissible: true);

    if (response != null && response.confirmed) {
      isArchiveView
          ? onTapBackToList(waitingItem)
          : onTapTableReady(waitingItem);
    }
  }

  Future<void> onTapTableReady(WaitingItem waitingItem) async {
    isTextSent = true;

    toggleIsLoadingFromParent();

    stopWatchTimer.onStartTimer();

    WaitingItemUpdateRequest waitingItemUpdateRequest =
        WaitingItemUpdateRequest();
    waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
    waitingItemUpdateRequest.action = ActionType.NOTIFY;
    WaitingItem updatedItem =
        await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);

    waitingItem.status = WaitingStatus.TEXT_SENT.name;
    await _waitingStorageService.updateWaiting(updatedItem);

    WaitingItemPublishRequest waitingItemPublishRequest =
        WaitingItemPublishRequest();
    waitingItemPublishRequest.waiting = updatedItem;
    await _dineSeaterApiService.publishWaitingItem(waitingItemPublishRequest);

    toggleIsLoadingFromParent();

    notifyListeners();
  }

  Future<void> onTapMiss(WaitingItem waitingItem) async {
    stopWatchTimer.onStopTimer();

    toggleIsLoadingFromParent();

    WaitingItemUpdateRequest waitingItemUpdateRequest =
        WaitingItemUpdateRequest();
    waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
    waitingItemUpdateRequest.action = ActionType.REPORT_MISSED;
    WaitingItem updatedItem =
        await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);

    waitingItem.status = WaitingStatus.MISSED.name;
    await _waitingStorageService.updateWaiting(updatedItem);

    WaitingItemPublishRequest waitingItemPublishRequest =
        WaitingItemPublishRequest();
    waitingItemPublishRequest.waiting = updatedItem;
    await _dineSeaterApiService.publishWaitingItem(waitingItemPublishRequest);

    toggleIsLoadingFromParent();

    notifyListeners();
  }

  Future<void> onTapConfirm(WaitingItem waitingItem) async {
    toggleIsLoadingFromParent();

    WaitingItemUpdateRequest waitingItemUpdateRequest =
        WaitingItemUpdateRequest();
    waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
    waitingItemUpdateRequest.action = ActionType.REPORT_ARRIVAL;
    WaitingItem updatedItem =
        await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);

    waitingItem.status = WaitingStatus.ARRIVED.name;
    await _waitingStorageService.updateWaiting(updatedItem);

    WaitingItemPublishRequest waitingItemPublishRequest =
        WaitingItemPublishRequest();
    waitingItemPublishRequest.waiting = updatedItem;
    await _dineSeaterApiService.publishWaitingItem(waitingItemPublishRequest);

    toggleIsLoadingFromParent();

    stopWatchTimer.onStopTimer();

    notifyListeners();
  }

  void onTimerEnd() {
    isTimerEnd = true;

    notifyListeners();
  }

  Future<void> onTapCancel(WaitingItem waitingItem) async {
    stopWatchTimer.onStopTimer();

    toggleIsLoadingFromParent();

    WaitingItemUpdateRequest waitingItemUpdateRequest =
        WaitingItemUpdateRequest();
    waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
    waitingItemUpdateRequest.action = ActionType.REPORT_CANCELLED;
    WaitingItem updatedItem =
        await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);

    waitingItem.status = WaitingStatus.CANCELLED.name;
    await _waitingStorageService.updateWaiting(updatedItem);

    WaitingItemPublishRequest waitingItemPublishRequest =
        WaitingItemPublishRequest();
    waitingItemPublishRequest.waiting = updatedItem;
    await _dineSeaterApiService.publishWaitingItem(waitingItemPublishRequest);

    toggleIsLoadingFromParent();

    notifyListeners();
  }

  Future<void> onTapBackToList(WaitingItem waitingItem) async {
    stopWatchTimer.onStopTimer();

    toggleIsLoadingFromParent();

    WaitingItemUpdateRequest waitingItemUpdateRequest =
        WaitingItemUpdateRequest();
    waitingItemUpdateRequest.waitingId = waitingItem.waitingId;
    waitingItemUpdateRequest.action = ActionType.REPORT_BACK_INITIAL_STATUS;
    WaitingItem updatedItem =
        await _dineSeaterApiService.updateWaitingItem(waitingItemUpdateRequest);

    waitingItem.status = WaitingStatus.WAITING.name;
    await _waitingStorageService.updateWaiting(updatedItem);

    WaitingItemPublishRequest waitingItemPublishRequest =
        WaitingItemPublishRequest();
    waitingItemPublishRequest.waiting = updatedItem;
    await _dineSeaterApiService.publishWaitingItem(waitingItemPublishRequest);

    toggleIsLoadingFromParent();

    notifyListeners();
  }
}
