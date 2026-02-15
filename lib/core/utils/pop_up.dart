import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:flutter/material.dart';

class PopMenu extends StatefulWidget {
  const PopMenu({super.key, this.onSelected, required this.list});
  final Function(dynamic)? onSelected;
  final List<String> list;
  @override
  State<PopMenu> createState() => _PopMenuState();
}

class _PopMenuState extends State<PopMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      icon: const Icon(
        Icons.arrow_drop_down,
        size: 20,
      ),
      onSelected: widget.onSelected,
      itemBuilder: (context) {
        return widget.list
            .map(
              (e) => PopupMenuItem(
                value: e,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e,
                    ),
                  ],
                ),
              ),
            )
            .toList();
      },
    );
  }
}

PopupMenuButton popMeuItemsForPops(
  context, {
  Function(dynamic)? onSelected,
  Widget? child,
  double pad = 0.0,
}) {
  return PopupMenuButton(
      color: AppStaticColor.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * .4, maxHeight: 280),
      icon: child,
      onSelected: onSelected,
      itemBuilder: (context) {
        return authos
            .map(
              (e) => PopupMenuItem(
                value: e,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        e['autho'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList();
      });
}

PopupMenuButton popActoionsMarkItemsForPops(
  context, {
  Function(dynamic)? onSelected,
  Function(dynamic)? moreDirsOnSelected,
  String next = '',
  bool moreDirs = false,
  Widget? icon,
}) {
  List<String> list = ['push${next.isNotEmpty ? ' to $next' : ''}'];
  List<String> listMore = ['push'];
  List<PopupMenuEntry<dynamic>> pops(List<String> list) {
    return list
        .map(
          (e) => PopupMenuItem(
            value: list.indexOf(e),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white70,
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!moreDirs)
                    Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  if (moreDirs)
                    popActionsFollowMarkItemsForPops(
                      context,
                      e,
                      next: next,
                      onSelected: moreDirsOnSelected,
                    ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  return PopupMenuButton(
    color: const Color.fromARGB(255, 0, 25, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * .4, maxHeight: 280),
    icon:icon?? const Icon(
      Icons.subdirectory_arrow_right,
      color: Color.fromARGB(255, 188, 151, 39),
    ),
    onSelected: onSelected,
    itemBuilder: (context) {
      return next.isNotEmpty && next.contains(',')
          ? pops(listMore)
          : pops(list);
    },
  );
}

PopupMenuButton popActionsFollowMarkItemsForPops(
  context,
  String e, {
  Function(dynamic)? onSelected,
  String next = '',
}) {
  List items = next.split(',');
  List<String> list = [];
  for (var it in items) {
    list.add('push to $it');
  }
  List<PopupMenuEntry<dynamic>> pops(List<String> list) {
    return list
        .map(
          (e) => PopupMenuItem(
            value: authos.indexWhere(
                (a) => a['autho'] == e.replaceFirst('push to ', '')),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white70,
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  return PopupMenuButton(
    color: const Color.fromARGB(255, 0, 25, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * .4, maxHeight: 280),
    icon: Text(
      e,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    onSelected: onSelected,
    itemBuilder: (context) {
      return pops(list);
    },
  );
}
