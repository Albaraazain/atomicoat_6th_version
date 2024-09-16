// lib/services/navigation_service.dart

import 'package:flutter/material.dart';

/// A service that provides navigation capabilities outside the widget context.
/// This is particularly useful for navigating from providers, services, or other
/// non-UI classes where a [BuildContext] is not readily available.
class NavigationService {
  /// A [GlobalKey] that uniquely identifies the [NavigatorState].
  /// This key allows the [NavigationService] to interact with the navigator
  /// without needing a [BuildContext].
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigates to the route specified by [routeName].
  ///
  /// Optionally, you can pass [arguments] to the route.
  ///
  /// Returns a [Future] that completes to the result of the navigation action.
  Future<dynamic>? navigateTo(
      String routeName, {
        Object? arguments,
      }) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Replaces the current route with the route specified by [routeName].
  ///
  /// Optionally, you can pass [arguments] to the new route.
  ///
  /// Returns a [Future] that completes to the result of the navigation action.
  Future<dynamic>? navigateReplacementTo(
      String routeName, {
        Object? arguments,
      }) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Pops the top-most route off the navigator.
  ///
  /// Optionally, you can pass a [result] that will be returned to the
  /// previous route.
  void goBack({dynamic result}) {
    navigatorKey.currentState?.pop(result);
  }

  /// Pops all routes until the predicate returns true.
  ///
  /// If [predicate] is null, it defaults to popping until the first route.
  void popUntil(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  /// Pops routes until the route with the specified [routeName] is reached.
  ///
  /// If no such route exists, it will pop until the first route.
  void popUntilRouteIs(String routeName) {
    navigatorKey.currentState?.popUntil((route) => route.settings.name == routeName);
  }

  /// Removes all the routes below the current route and pushes a new named route.
  ///
  /// This is useful for navigating to a new screen and removing all previous
  /// screens from the stack, preventing the user from navigating back.
  Future<dynamic>? navigateAndRemoveUntil(
      String newRouteName, {
        bool Function(Route<dynamic>)? predicate,
        Object? arguments,
      }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      newRouteName,
      predicate ?? (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
}
