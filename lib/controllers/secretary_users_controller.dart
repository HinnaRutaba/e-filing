import 'dart:async';

import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/pagination_model.dart';
import 'package:efiling_balochistan/models/secretary_department_users_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecretaryUsersState {
  /// Every page loaded so far, in order.
  final List<SecretaryDepartmentUserModel> items;
  final PaginationModel? pagination;

  /// Loading page 1 (first load, refresh or a new search).
  final bool loading;

  /// Loading the page after [pagination]'s current one.
  final bool loadingMore;
  final String? error;

  /// The search text sent as `q`.
  final String query;

  /// Sent as `section_id`; null for every section.
  final int? sectionId;

  /// One of [SecretaryUsersFiltersModel.sortOptions].
  final String sort;

  /// `asc` or `desc`.
  final String direction;

  /// Sections and sort options from the last response, kept while reloading.
  final SecretaryUsersFiltersModel? filters;

  const SecretaryUsersState({
    this.items = const [],
    this.pagination,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.query = '',
    this.sectionId,
    this.sort = 'pending',
    this.direction = 'desc',
    this.filters,
  });

  bool get hasMore => pagination?.hasMore ?? false;

  bool get descending => direction == 'desc';

  /// Whether the list differs from the default (all sections, most pending
  /// first).
  bool get filtered =>
      sectionId != null || sort != 'pending' || direction != 'desc';

  int get total => pagination?.total ?? items.length;

  SecretaryUsersState copyWith({
    List<SecretaryDepartmentUserModel>? items,
    PaginationModel? pagination,
    bool? loading,
    bool? loadingMore,
    String? Function()? error,
    String? query,
    int? Function()? sectionId,
    String? sort,
    String? direction,
    SecretaryUsersFiltersModel? filters,
  }) {
    return SecretaryUsersState(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error != null ? error() : this.error,
      query: query ?? this.query,
      sectionId: sectionId != null ? sectionId() : this.sectionId,
      sort: sort ?? this.sort,
      direction: direction ?? this.direction,
      filters: filters ?? this.filters,
    );
  }
}

class SecretaryUsersController
    extends BaseControllerState<SecretaryUsersState> {
  SecretaryUsersController(super.state, super.ref);

  /// Users fetched per request; "Load more" adds this many at a time.
  static const int perPage = 10;
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  Timer? _debounce;

  /// Bumped on every page-1 request so a slower, older response (e.g. for a
  /// query the user has since changed) can't overwrite a newer one.
  int _requestId = 0;

  int? get _userDesgId =>
      ref.read(authController).currentDesignation?.userDesgId;

  /// Reloads from page 1 with the current query and filters.
  Future<void> initData() async {
    _debounce?.cancel();
    final requestId = ++_requestId;
    state = state.copyWith(
      loading: true,
      loadingMore: false,
      error: () => null,
    );
    try {
      final result = await ref
          .read(dashboardRepo)
          .getSecretaryDepartmentUsers(
            userDesgId: _userDesgId,
            query: state.query.trim(),
            sectionId: state.sectionId,
            sort: state.sort,
            direction: state.direction,
            perPage: perPage,
          );
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: result.items,
        pagination: result.pagination,
        filters: result.filters,
        loading: false,
      );
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(loading: false, error: () => handleException(e));
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    final requestId = _requestId;
    state = state.copyWith(loadingMore: true, error: () => null);
    try {
      final result = await ref
          .read(dashboardRepo)
          .getSecretaryDepartmentUsers(
            userDesgId: _userDesgId,
            query: state.query.trim(),
            sectionId: state.sectionId,
            sort: state.sort,
            direction: state.direction,
            perPage: perPage,
            page: (state.pagination?.currentPage ?? 1) + 1,
          );
      // A page-1 reload started meanwhile; this page belongs to the old list.
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...result.items],
        pagination: result.pagination,
        loadingMore: false,
      );
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        loadingMore: false,
        error: () => handleException(e),
      );
    }
  }

  /// Searches the server after typing pauses.
  void setQuery(String value) {
    if (value.trim() == state.query.trim()) {
      state = state.copyWith(query: value);
      return;
    }
    state = state.copyWith(query: value);
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, initData);
  }

  /// Unlike [setQuery], reloads straight away.
  void clearQuery() {
    final hadQuery = state.query.trim().isNotEmpty;
    state = state.copyWith(query: '');
    if (hadQuery) initData();
  }

  void setSection(int? sectionId) {
    if (sectionId == state.sectionId) return;
    state = state.copyWith(sectionId: () => sectionId);
    initData();
  }

  /// Names and sections read naturally A to Z; counts start with the highest.
  void setSort(String sort) {
    if (sort == state.sort) return;
    final alphabetical = sort == 'name' || sort == 'section';
    state = state.copyWith(
      sort: sort,
      direction: alphabetical ? 'asc' : 'desc',
    );
    initData();
  }

  void toggleDirection() {
    state = state.copyWith(direction: state.descending ? 'asc' : 'desc');
    initData();
  }

  /// Back to all sections, most pending first. Leaves the search alone.
  void resetFilters() {
    if (!state.filtered) return;
    state = state.copyWith(
      sectionId: () => null,
      sort: 'pending',
      direction: 'desc',
    );
    initData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final secretaryUsersController =
    StateNotifierProvider<SecretaryUsersController, SecretaryUsersState>(
      (ref) => SecretaryUsersController(const SecretaryUsersState(), ref),
    );
