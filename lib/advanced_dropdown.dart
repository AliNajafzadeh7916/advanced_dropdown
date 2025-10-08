import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final bool isSearch;
  final bool isMultiSelect;
  final Function(dynamic) onChanged;
  final InputDecoration? inputDecoration;
  final BoxDecoration? decoration;
  final BoxDecoration? dropdownDecoration;

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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final List<String> _selectedItems = [];
  String? _selectedItem;
  String _searchText = '';

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

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    final filteredItems = widget.items
        .where((item) =>
            item.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown, // close when tapping outside
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                width: size.width,
                top: offset.dy + size.height + 5,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: widget.dropdownDecoration ??
                          BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                  _overlayEntry?.remove();
                                  _overlayEntry = _createOverlayEntry();
                                  Overlay.of(context).insert(_overlayEntry!);
                                },
                              ),
                            ),
                          Flexible(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: filteredItems.map((item) {
                                final isSelected =
                                    _selectedItems.contains(item);
                                return ListTile(
                                  title: Text(item),
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
                        ],
                      ),
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

  void _onItemSelect(String item) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
        widget.onChanged(_selectedItems);
      } else {
        _selectedItem = item;
        widget.onChanged(item);
        _closeDropdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
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
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}