import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_status.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/first_page_error_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/first_page_progress_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/new_page_error_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/new_page_progress_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/no_items_found_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PagingStatusWidget<PageKeyType, T extends PagingItem>
    extends ConsumerWidget {
  final PagedChildStatusBuilderDelegate? builderDelegate;

  // 加载下一页失败时的重试回调
  final PagingDataController pagingBuilderController;

  final PagedLayoutProtocol layoutProtocol;
  final bool shrinkWrapFirstPageIndicators;

  WidgetBuilder? get _noMoreItemsIndicatorBuilder =>
      builderDelegate?.noMoreItemsIndicatorBuilder ?? (_) => Container();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      builderDelegate?.newPageProgressIndicatorBuilder ??
      (_) => const NewPageProgressIndicator();

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      builderDelegate?.firstPageProgressIndicatorBuilder ??
      (_) => const FirstPageProgressIndicator();

  bool get _shrinkWrapFirstPageIndicators => shrinkWrapFirstPageIndicators;

  PagedLayoutProtocol get _layoutProtocol => layoutProtocol;

  ErrorIndicatorBuilder get _newPageErrorIndicatorBuilder =>
      builderDelegate?.newPageErrorIndicatorBuilder ??
      (_, callback) => NewPageErrorIndicator(
            onTap: callback,
          );

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      builderDelegate?.noItemsFoundIndicatorBuilder ??
      (_) => const NoItemsFoundIndicator();

  ErrorIndicatorBuilder get _firstPageErrorIndicatorBuilder =>
      builderDelegate?.firstPageErrorIndicatorBuilder ??
      (_, callBack) {
        return FirstPageErrorIndicator(
          onTryAgain: callBack,
        );
      };

  final AutoDisposeFamilyNotifierProvider<PagingController<PageKeyType, T>,
      PagingState<PageKeyType, T>, PageKeyType> pagingControllerProvider;
  const PagingStatusWidget({
    super.key,
    required this.pagingControllerProvider,
    required this.builderDelegate,
    required this.pagingBuilderController,
    required this.layoutProtocol,
    required this.shrinkWrapFirstPageIndicators,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingStatus =
        ref.watch(pagingControllerProvider.select((value) => value.status));
    Widget child;
    switch (pagingStatus) {
      case PagingStatus.loadingFirstPage:
        child = FirstPageStatusIndicatorBuilder(
          builder: _firstPageProgressIndicatorBuilder,
          shrinkWrap: _shrinkWrapFirstPageIndicators,
          layoutProtocol: _layoutProtocol,
        );
        break;
      case PagingStatus.ongoing:
        child = _newPageProgressIndicatorBuilder(context);
        break;
      case PagingStatus.subsequentPageError:
        return _newPageErrorIndicatorBuilder(context, () {
          retryLastFailedRequest(ref);
        });
      case PagingStatus.completed:
        child = _noMoreItemsIndicatorBuilder?.call(context) ?? Container();
        break;
      case PagingStatus.noItemsFound:
        child = FirstPageStatusIndicatorBuilder(
          builder: _noItemsFoundIndicatorBuilder,
          shrinkWrap: _shrinkWrapFirstPageIndicators,
          layoutProtocol: _layoutProtocol,
        );
      default:
        child = FirstPageStatusIndicatorBuilder(
          builder: (context) {
            return _firstPageErrorIndicatorBuilder(context, () {
              retryLastFailedRequest(ref);
            });
          },
          shrinkWrap: _shrinkWrapFirstPageIndicators,
          layoutProtocol: _layoutProtocol,
        );
    }

    if (builderDelegate?.animateTransitions ?? false) {
      if (_layoutProtocol == PagedLayoutProtocol.sliver) {
        return SliverAnimatedSwitcher(
          duration: builderDelegate?.transitionDuration ??
              const Duration(milliseconds: 250),
          child: child,
        );
      } else {
        return AnimatedSwitcher(
          duration: builderDelegate?.transitionDuration ??
              const Duration(milliseconds: 250),
          child: child,
        );
      }
    } else {
      return child;
    }
  }

  /// Retry the last failed request.
  /// This method updates the state of the PagingController to indicate that a new request is in progress,
  /// then attempts to retrieve the data for the next page.
  /// If the data retrieval is successful, it appends the new data to the current paging data list
  /// and updates the next page key.
  /// If the data retrieval fails, it updates the state of the PagingController to indicate an error.
  ///
  /// @throws Exception If an exception occurs during the retry process, it is caught and passed
  /// to the loadError method of the PagingController.
  Future<void> retryLastFailedRequest(WidgetRef ref) async {
    // Update the state of the PagingController to indicate that a new request is in progress
    ref.read(pagingControllerProvider.notifier).onGoing();
    // Retrieve the next page key from the PagingController
    var nextPageKey = ref.read(pagingControllerProvider).nextPageKey;
    try {
      // Retry retrieving the data for the next page
      var data =
          await pagingBuilderController.retryLastFailedRequest(nextPageKey);
      // If the data retrieval is successful, append the new data and update the next page key
      if (data.error == null) {
        ref
            .read(pagingControllerProvider.notifier)
            .appendPage(data.itemList as List<T>, data.nextPageKey);
      }
      // If the data retrieval fails, update the state of the PagingController to indicate an error
      else {
        ref.read(pagingControllerProvider.notifier).loadError(data.error);
      }
    } catch (e) {
      // If an exception occurs during the retry process, pass it to the loadError method of the PagingController
      ref.read(pagingControllerProvider.notifier).loadError(e);
    }
  }
}
