import 'package:flutter/material.dart';

/// A customizable dropdown widget that supports:
/// - Single select or multi-select
/// - Optional search
/// - Optional decorations
class CustomDropdown extends StatefulWidget {
  final List<String> items; // The list of items to show in the dropdown
  final bool isSearch; // Whether to show a search box
  final bool isMultiSelect; // Whether multiple selections are allowed
  final Function(dynamic) onChanged; // Callback when selection changes
  final InputDecoration? inputDecoration; // Decoration for search field
  final BoxDecoration? decoration; // Decoration for main dropdown button
  final BoxDecoration? dropdownDecoration; // Decoration for the popup dropdown

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.isSearch = false,
    this.isMultiSelect = false,
    this.inputDecoration,
    this.decoration,
    this.dropdownDecoration,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  // Used to position the dropdown relative to the button
  final LayerLink _layerLink = LayerLink();

  // Holds the currently displayed overlay (popup)
  OverlayEntry? _overlayEntry;

  // Stores the selected items for multi-select mode
  final List<String> _selectedItems = [];

  // Stores the selected item for single-select mode
  String? _selectedItem;

  // Stores the current search input
  String _searchText = '';

  /// Toggles the dropdown overlay: opens if closed, closes if open
  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _closeDropdown();
    }
  }

  /// Closes the dropdown overlay
  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Rebuilds the dropdown overlay (used to refresh UI like checkbox state)
  void _rebuildDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Creates the dropdown popup using OverlayEntry
  OverlayEntry _createOverlayEntry() {
    // Get size and position of the dropdown button
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    // Filter the items based on the search text
    final filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    // Create the dropdown popup as an OverlayEntry
    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown, // Close dropdown when tapping outside
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Transparent background to capture taps outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDropdown,
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Dropdown popup
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 5), // Show below the button
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
                    constraints: const BoxConstraints(
                      maxHeight: 400, // Make dropdown taller but not fullscreen
                      minHeight: 100,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optional search box
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
                                _rebuildDropdown(); // Refresh list
                              },
                            ),
                          ),

                        // List of items (with checkboxes if multi-select)
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
                                    _onItemSelect(item); // single select
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        // "OK" button for multi-select mode
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
      ),
    );
  }

  /// Handles item selection
  void _onItemSelect(String item) {
    setState(() {
      if (widget.isMultiSelect) {
        // Toggle selection for multi-select
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }

        // Notify parent of changes
        widget.onChanged(_selectedItems);

        // Rebuild dropdown to reflect checkbox state
        _rebuildDropdown();
      } else {
        // For single select, select item and close dropdown
        _selectedItem = item;
        widget.onChanged(item);
        _closeDropdown();
      }
    });
  }

  /// Builds the main dropdown button UI
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink, // Links to the follower used in overlay
      child: GestureDetector(
        onTap: _toggleDropdown, // Tap to open or close dropdown
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: widget.decoration ??
              BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Selected item(s) text
              Expanded(
                child: Text(
                  widget.isMultiSelect
                      ? _selectedItems.isEmpty
                          ? 'Select items'
                          : _selectedItems.join(', ')
                      : _selectedItem ?? 'Select item',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Dropdown icon
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}