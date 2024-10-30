import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_status.dart';
import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/first_page_error_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/first_page_progress_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/new_page_error_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/new_page_progress_indicator.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/no_items_found_indicator.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PagingStatusWidget<PageKeyType, T extends PagingItem> extends ConsumerWidget {
  final PagedChildStatusBuilderDelegate? builderDelegate;

  // Callback for retrying when a page load fails
  final PagingDataController pagingDataController;

  final PagedLayoutProtocol layoutProtocol;
  final bool shrinkWrapFirstPageIndicators;

  final bool isPersistent;

  WidgetBuilder? get _noMoreItemsIndicatorBuilder => builderDelegate?.noMoreItemsIndicatorBuilder ?? (_) => Container();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      builderDelegate?.newPageProgressIndicatorBuilder ?? (_) => const NewPageProgressIndicator();

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      builderDelegate?.firstPageProgressIndicatorBuilder ?? (_) => const FirstPageProgressIndicator();

  bool get _shrinkWrapFirstPageIndicators => shrinkWrapFirstPageIndicators;

  PagedLayoutProtocol get _layoutProtocol => layoutProtocol;

  ErrorIndicatorBuilder get _newPageErrorIndicatorBuilder =>
      builderDelegate?.newPageErrorIndicatorBuilder ??
      (_, callback) => NewPageErrorIndicator(
            onTap: callback,
          );

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      builderDelegate?.noItemsFoundIndicatorBuilder ?? (_) => const NoItemsFoundIndicator();

  ErrorIndicatorBuilder get _firstPageErrorIndicatorBuilder =>
      builderDelegate?.firstPageErrorIndicatorBuilder ??
      (_, callBack) {
        return FirstPageErrorIndicator(
          onTryAgain: callBack,
        );
      };

  const PagingStatusWidget({
    super.key,
    required this.builderDelegate,
    required this.pagingDataController,
    required this.layoutProtocol,
    required this.shrinkWrapFirstPageIndicators,
    this.isPersistent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PagingStatus pagingStatus;
    if (isPersistent) {
      pagingStatus = ref.watch(persistentPagingControllerProvider(pagingDataController.pageKey).select((value) => value.status));
    } else {
      pagingStatus = ref.watch(pagingControllerProvider(pagingDataController.pageKey).select((value) => value.status));
    }
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
        break;
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
          duration: builderDelegate?.transitionDuration ?? const Duration(milliseconds: 250),
          child: child,
        );
      } else {
        return AnimatedSwitcher(
          duration: builderDelegate?.transitionDuration ?? const Duration(milliseconds: 250),
          child: child,
        );
      }
    } else {
      return child;
    }
  }

  /// Retry the last failed request.
  Future<void> retryLastFailedRequest(WidgetRef ref) async {
    // Indicate that a new request is in progress
    PagingDataControllerInterface pagingDataControllerInterface = getPagingDataControllerInterface(ref, isPersistent, pagingDataController.pageKey);
    pagingDataControllerInterface.onGoing();

    var nextPageKey;
    if (isPersistent) {
      nextPageKey = ref.read(persistentPagingControllerProvider(pagingDataController.pageKey)).nextPageKey;
    } else {
      nextPageKey = ref.read(pagingControllerProvider(pagingDataController.pageKey)).nextPageKey;
    }
    try {
      // Retry retrieving the data for the next page
      var data = await pagingDataController.retryLastFailedRequest(nextPageKey);

      // Append data if successful, otherwise load error
      if (data.error == null) {
        pagingDataControllerInterface.appendPage(data.itemList as List<T>, data.nextPageKey);
      } else {
        pagingDataControllerInterface.loadError(data.error);
      }
    } catch (e) {
      pagingDataControllerInterface.loadError(e);
    }
  }

  /// Helper to access the correct notifier based on persistence
}
