import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../utils/screen_utils.dart';

class AppNavigationScaffold extends StatelessWidget {
  const AppNavigationScaffold({
    required this.currentRoute,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.onBeforeNavigate,
    super.key,
  });

  final String currentRoute;
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Future<bool> Function()? onBeforeNavigate;

  static const _items = [
    _NavigationItem(
      label: 'invoices',
      icon: Icons.receipt_long_outlined,
      route: AppRoutes.invoices,
    ),
    _NavigationItem(
      label: 'create_invoice',
      icon: Icons.add_circle_outline,
      route: AppRoutes.invoiceForm,
    ),
    _NavigationItem(
      label: 'customers',
      icon: Icons.people_alt_outlined,
      route: AppRoutes.customers,
    ),
    _NavigationItem(
      label: 'shop_info',
      icon: Icons.storefront_outlined,
      route: AppRoutes.shop,
    ),
    _NavigationItem(
      label: 'settings',
      icon: Icons.settings_outlined,
      route: AppRoutes.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _items.indexWhere(
      (item) => item.route == currentRoute,
    );
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;

    if (ScreenUtils.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: safeIndex,
              items: _items,
              onSelect: (index) => _goTo(_items[index].route),
            ),
            Expanded(
              child: Scaffold(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLowest,
                appBar: title == null
                    ? null
                    : AppBar(
                        title: Text(title!),
                        actions: actions,
                        surfaceTintColor: Colors.transparent,
                      ),
                floatingActionButton: floatingActionButton,
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(key: ValueKey(currentRoute), child: body),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              surfaceTintColor: Colors.transparent,
            ),
      floatingActionButton:
          floatingActionButton ??
          FloatingActionButton(
            tooltip: 'create_invoice'.tr,
            onPressed: () => _goTo(AppRoutes.invoiceForm),
            child: const Icon(Icons.add),
          ),
      body: body,
      bottomNavigationBar: NavigationBar(
        height: 76,
        elevation: 1,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: safeIndex,
        onDestinationSelected: (index) => _goTo(_items[index].route),

        destinations:
        List.generate(
          _items.length,
              (index) {
            final item = _items[index];
            final isSelected = safeIndex == index;

            return NavigationDestination(
              icon: Icon(
                item.icon,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),

              label: item.label.tr,
            );
          },
        )??
        _items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon,),
                label: item.label.tr,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _goTo(String route) async {
    if (Get.currentRoute != route) {
      final canNavigate = await onBeforeNavigate?.call() ?? true;
      if (!canNavigate) {
        return;
      }
      Get.offNamed(route);
    }
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.items,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<_NavigationItem> items;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpanded = ScreenUtils.width(context) >= 1180;

    return Container(
      width: isExpanded ? 256 : 92,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.primary.withValues(alpha: 0.18)),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _BrandHeader(isExpanded: isExpanded),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;
                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  isExpanded: isExpanded,
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _ProfilePlaceholder(isExpanded: isExpanded),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: isExpanded
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.receipt_long, color: colorScheme.onPrimary),
        ),
        if (isExpanded) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'app_name'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'billing_workspace'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: item.label.tr,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 14 : 0,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.35))
                : null,
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label.tr,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: isExpanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.secondaryContainer,
            child: Icon(
              Icons.person_outline,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'owner'.tr,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    'local_account'.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
