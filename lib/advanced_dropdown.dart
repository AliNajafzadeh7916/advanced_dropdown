import 'package:flutter/material.dart';

/// 🧩 AdvancedDropdown
/// A flexible, fully customizable dropdown for Flutter.
///
/// ✅ Features:
/// - Single select & multi-select
/// - Searchable dropdown
/// - Preselected values from backend
/// - Works with List<String> or List<Map<String, dynamic>>
/// - Customizable decoration, colors, and icons
/// - Max selection limit
/// - Chips with remove option for multi-select
///
/// Example:
/// ```dart
/// AdvancedDropdown(
///   items: [
///     {'id': 1, 'name': 'Flutter'},
///     {'id': 2, 'name': 'React'},
///     {'id': 3, 'name': 'Vue'},
///   ],
///   displayField: 'name',
///   valueField: 'id',
///   isMultiSelect: true,
///   initialValues: [1, 3],
///   maxSelection: 3,
///   chipColor: Colors.blue.shade100,
///   onChanged: (val) => print(val),
/// )
/// ```
class AdvancedDropdown extends StatefulWidget {
  /// Dropdown items (either `List<String>` or `List<Map<String, dynamic>>`)
  final List<dynamic> items;

  /// Callback when selection changes
  final Function(dynamic) onChanged;

  /// Enable multi-selection mode
  final bool isMultiSelect;

  /// Enable search field
  final bool isSearch;

  /// Optional field names when items are Map
  final String? displayField;
  final String? valueField;

  /// Preselected single value (for single-select mode)
  final dynamic initialValue;

  /// Preselected multiple values (for multi-select mode)
  final List<dynamic>? initialValues;

  /// Max selection limit (for multi-select)
  final int? maxSelection;

  /// Dropdown decorations
  final BoxDecoration? decoration;
  final BoxDecoration? dropdownDecoration;
  final InputDecoration? inputDecoration;

  /// Hint when nothing is selected
  final String hintText;

  /// Chip customization (for multi-select)
  final Color? chipColor;
  final TextStyle? chipTextStyle;

  /// Text customization
  final TextStyle? selectedTextStyle;
  final TextStyle? itemTextStyle;

  /// Dropdown icon
  final Widget? icon;

  const AdvancedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.isMultiSelect = false,
    this.isSearch = false,
    this.displayField,
    this.valueField,
    this.initialValue,
    this.initialValues,
    this.maxSelection,
    this.decoration,
    this.dropdownDecoration,
    this.inputDecoration,
    this.hintText = "Select an option",
    this.chipColor,
    this.chipTextStyle,
    this.selectedTextStyle,
    this.itemTextStyle,
    this.icon,
  });

  @override
  State<AdvancedDropdown> createState() => _AdvancedDropdownState();
}

class _AdvancedDropdownState extends State<AdvancedDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchText = '';

  dynamic _selectedValue; // For single select
  List<dynamic> _selectedValues = []; // For multi select

  @override
  void initState() {
    super.initState();
    // Load initial selected items
    if (widget.isMultiSelect && widget.initialValues != null) {
      _selectedValues = List.from(widget.initialValues!);
    } else if (!widget.isMultiSelect && widget.initialValue != null) {
      _selectedValue = widget.initialValue;
    }
  }

  /// Extracts display text for any type (Map or String)
  String _getDisplayText(dynamic item) {
    if (item is Map && widget.displayField != null) {
      return item[widget.displayField].toString();
    }
    return item.toString();
  }

  /// Extracts comparable value (used for equality)
  dynamic _getItemValue(dynamic item) {
    if (item is Map && widget.valueField != null) {
      return item[widget.valueField];
    }
    return item;
  }

  /// Check if the item is selected
  bool _isItemSelected(dynamic item) {
    final value = _getItemValue(item);
    if (widget.isMultiSelect) {
      return _selectedValues.contains(value);
    } else {
      return _selectedValue == value;
    }
  }

  /// Toggle dropdown visibility
  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _closeDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _rebuildDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Handles single and multi selection
  void _onItemSelect(dynamic item) {
    final value = _getItemValue(item);
    setState(() {
      if (widget.isMultiSelect) {
        // Handle multi-selection
        if (_selectedValues.contains(value)) {
          _selectedValues.remove(value);
        } else {
          // Check max limit
          if (widget.maxSelection != null &&
              _selectedValues.length >= widget.maxSelection!) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('You can select up to ${widget.maxSelection} items'),
              ),
            );
            return;
          }
          _selectedValues.add(value);
        }
        widget.onChanged(_selectedValues);
        _rebuildDropdown();
      } else {
        // Handle single-selection
        _selectedValue = value;
        widget.onChanged(value);
        _closeDropdown();
      }
    });
  }

  /// Create overlay dropdown
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final filteredItems = widget.items
        .where((item) => _getDisplayText(item)
            .toLowerCase()
            .contains(_searchText.toLowerCase()))
        .toList();

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(child: GestureDetector(onTap: _closeDropdown)),
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
                    constraints:
                        const BoxConstraints(maxHeight: 350, minHeight: 80),
                    child: Column(
                      children: [
                        // Search Field
                        if (widget.isSearch)
                          Padding(
                            padding: const EdgeInsets.all(8),
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
                        // Item List
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: filteredItems.map((item) {
                              final isSelected = _isItemSelected(item);
                              return ListTile(
                                title: Text(
                                  _getDisplayText(item),
                                  style: widget.itemTextStyle,
                                ),
                                trailing: widget.isMultiSelect
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => _onItemSelect(item),
                                      )
                                    : null,
                                onTap: () => _onItemSelect(item),
                              );
                            }).toList(),
                          ),
                        ),
                        // OK button for multi-select
                        if (widget.isMultiSelect)
                          Padding(
                            padding: const EdgeInsets.all(8),
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
      ),
    );
  }

  /// Remove a chip (multi select)
  void _removeChip(dynamic value) {
    setState(() {
      _selectedValues.remove(value);
      widget.onChanged(_selectedValues);
    });
  }

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
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
          child: Row(
            children: [
              // Show selected chips for multi-select
              Expanded(
                child: widget.isMultiSelect
                    ? Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: _selectedValues.isEmpty
                            ? [
                                Text(
                                  widget.hintText,
                                  style: TextStyle(color: Colors.grey.shade600),
                                )
                              ]
                            : _selectedValues.map((value) {
                                final item = widget.items.firstWhere(
                                  (i) => _getItemValue(i) == value,
                                  orElse: () => null,
                                );
                                final text = item != null
                                    ? _getDisplayText(item)
                                    : value.toString();
                                return Chip(
                                  label: Text(
                                    text,
                                    style: widget.chipTextStyle ??
                                        const TextStyle(fontSize: 13),
                                  ),
                                  backgroundColor: widget.chipColor ??
                                      Colors.blue.shade100,
                                  onDeleted: () => _removeChip(value),
                                );
                              }).toList(),
                      )
                    : Text(
                        _selectedValue != null
                            ? _getDisplayText(widget.items.firstWhere(
                                (i) => _getItemValue(i) == _selectedValue,
                                orElse: () => _selectedValue))
                            : widget.hintText,
                        style: widget.selectedTextStyle ??
                            TextStyle(color: Colors.grey.shade800),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              widget.icon ??
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}