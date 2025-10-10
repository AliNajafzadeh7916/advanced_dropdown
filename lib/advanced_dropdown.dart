import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// 🧩 Advanced Dropdown for Flutter
/// ------------------------------------------------------------
/// A fully customizable dropdown widget supporting:
/// ✅ Single Select (default)
/// ✅ Multi Select with inline removable chips
/// ✅ Optional Search
/// ✅ Max selection limit
/// ✅ Custom decoration and chip styling
///
/// Example:
/// ```dart
/// CustomDropdown(
///   items: ['Apple', 'Banana', 'Cherry', 'Mango'],
///   isMultiSelect: true,
///   isSearch: true,
///   maxSelection: 3,
///   chipColor: Colors.blue.shade100,
///   chipTextColor: Colors.black,
///   chipRemoveIconColor: Colors.black54,
///   onChanged: (values) {
///     print(values); // prints list or selected value
///   },
/// )
/// ```
/// ------------------------------------------------------------
class CustomDropdown extends StatefulWidget {
  /// The list of items to show in the dropdown
  final List<String> items;

  /// Callback when selection changes
  final Function(dynamic) onChanged;

  /// Whether to enable the search bar inside dropdown
  final bool isSearch;

  /// Whether multiple selections are allowed
  final bool isMultiSelect;

  /// Optional decoration for the main dropdown button
  final BoxDecoration? decoration;

  /// Optional decoration for the dropdown popup
  final BoxDecoration? dropdownDecoration;

  /// Optional decoration for the search field
  final InputDecoration? inputDecoration;

  /// Optional dropdown icon (default: arrow)
  final Icon? icon;

  /// Maximum number of items that can be selected in multi-select
  final int? maxSelection;

  /// Background color of selected chips (for multi-select)
  final Color chipColor;

  /// Text color of selected chips
  final Color chipTextColor;

  /// Remove (×) icon color for chips
  final Color chipRemoveIconColor;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.isSearch = false,
    this.isMultiSelect = false,
    this.inputDecoration,
    this.decoration,
    this.dropdownDecoration,
    this.icon,
    this.maxSelection,
    this.chipColor = const Color(0xFFD0E6FF),
    this.chipTextColor = Colors.black,
    this.chipRemoveIconColor = Colors.black54,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink(); // For positioning the dropdown
  OverlayEntry? _overlayEntry;

  String? _selectedItem; // For single select
  final List<String> _selectedItems = []; // For multi-select
  String _searchText = ''; // For filtering

  /// Toggles dropdown visibility
  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _closeDropdown();
    }
  }

  /// Closes dropdown
  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Rebuilds dropdown overlay
  void _rebuildDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Creates dropdown overlay with search & list
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            // Transparent area to close dropdown when tapping outside
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDropdown,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Actual dropdown
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height + 5),
              showWhenUnlinked: false,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: size.width,
                  decoration: widget.dropdownDecoration ??
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search box
                      if (widget.isSearch)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: widget.inputDecoration ??
                                const InputDecoration(
                                  hintText: 'Search...',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                            onChanged: (val) {
                              setState(() => _searchText = val);
                              _rebuildDropdown();
                            },
                          ),
                        ),

                      // List of items
                      Flexible(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: filteredItems.map((item) {
                            final isSelected = _selectedItems.contains(item);
                            return ListTile(
                              title: Text(item),
                              trailing: widget.isMultiSelect
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _onItemSelect(item),
                                    )
                                  : null,
                              onTap: () {
                                if (!widget.isMultiSelect) {
                                  _onItemSelect(item);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      // OK button for multi-select
                      if (widget.isMultiSelect)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _closeDropdown,
                            child: const Text("OK"),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles item selection
  void _onItemSelect(String item) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          // Handle selection limit
          if (widget.maxSelection != null &&
              _selectedItems.length >= widget.maxSelection!) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('You can select up to ${widget.maxSelection} items'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
          _selectedItems.add(item);
        }
        widget.onChanged(_selectedItems);
        _rebuildDropdown();
      } else {
        _selectedItem = item;
        widget.onChanged(item);
        _closeDropdown();
      }
    });
  }

  /// Builds chips inside main dropdown button (multi-select only)
  Widget _buildChips() {
    return Wrap(
      spacing: 6,
      runSpacing: -6,
      children: _selectedItems.map((item) {
        return Chip(
          label: Text(
            item,
            style: TextStyle(color: widget.chipTextColor, fontSize: 14),
          ),
          backgroundColor: widget.chipColor,
          deleteIcon: Icon(Icons.close, color: widget.chipRemoveIconColor),
          onDeleted: () {
            setState(() {
              _selectedItems.remove(item);
              widget.onChanged(_selectedItems);
            });
          },
        );
      }).toList(),
    );
  }

  /// Builds the main dropdown button
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: widget.decoration ??
              BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selected items (chips or text)
              Expanded(
                child: widget.isMultiSelect
                    ? (_selectedItems.isEmpty
                        ? const Text('Select items')
                        : _buildChips())
                    : Text(_selectedItem ?? 'Select item'),
              ),
              const SizedBox(width: 6),
              widget.icon ?? const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}