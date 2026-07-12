import 'package:flutter/material.dart';

class OrganizationFilterBar extends StatelessWidget {
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final Widget? filterDropdown;
  final VoidCallback? onClearFilters;

  const OrganizationFilterBar({
    super.key,
    required this.searchHint,
    this.onSearchChanged,
    this.filterDropdown,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          if (filterDropdown != null) filterDropdown!,
          if (onClearFilters != null)
            TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }
}
