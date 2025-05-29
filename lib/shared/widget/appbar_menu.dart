import 'package:flutter/material.dart';
import 'package:bee_movies/models/gender_model.dart';

class PopupFilterMenu extends StatefulWidget {
  final List<Gender> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const PopupFilterMenu({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<PopupFilterMenu> createState() => _PopupFilterMenuState();
}

class _PopupFilterMenuState extends State<PopupFilterMenu> {
  late String _localSelectedCategory;

  @override
  void initState() {
    super.initState();
    _localSelectedCategory = widget.selectedCategory;
  }

  void _openCustomMenu(BuildContext context, Offset position) {
    final sortedCategories = [...widget.categories]
      ..sort((a, b) => a.name.compareTo(b.name));

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setStateInsideMenu) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrar por género',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _localSelectedCategory,
                    isExpanded: true,
                    items:
                        sortedCategories.map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender.name,
                            child: Text(gender.name),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _localSelectedCategory = newValue;
                        });
                        setStateInsideMenu(() {}); // Redibuja dentro del popup
                        widget.onCategorySelected(newValue);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('L O G I N'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant PopupFilterMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _localSelectedCategory = widget.selectedCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            final RenderBox button = ctx.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(ctx).context.findRenderObject() as RenderBox;
            final Offset position = button.localToGlobal(
              Offset.zero,
              ancestor: overlay,
            );
            _openCustomMenu(context, position);
          },
        );
      },
    );
  }
}
