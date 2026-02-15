import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:flutter/material.dart';

class VerticalTable extends StatefulWidget {
  final List<String> headers;
  final List<String> data;
  final bool isEdit;
  final bool isNew;

  const VerticalTable({
    super.key,
    required this.headers,
    required this.data,
    this.isEdit = false,
    this.isNew = false,
  });

  @override
  State<VerticalTable> createState() => VerticalTableState();
}

class VerticalTableState extends State<VerticalTable> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    if ((widget.isEdit || widget.isNew) && widget.data.isNotEmpty) {
      _controllers = widget.data
          .map((value) => TextEditingController(text: value))
          .toList();
    } else {
      _controllers = [];
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> getUpdatedValues() {
    return _controllers.map((controller) => controller.text).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.headers.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppStaticColor.black, width: 1),
                  ),
                  child: Text(
                    widget.headers[index],
                    style: Styles.textStyle14600.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical:
                          ((widget.isEdit == true || widget.isNew == true) &&
                                  !["STATES", "HOLD"]
                                      .contains(widget.headers[index]))
                              ? 10
                              : 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppStaticColor.black, width: 1),
                    color: ((widget.isEdit == true || widget.isNew == true) &&
                            !["STATES", "HOLD"].contains(widget.headers[index]))
                        ? Colors.grey.withValues(alpha: .3)
                        : null,
                  ),
                  child: ((widget.isEdit == true || widget.isNew == true) &&
                          !["STATES", "HOLD"].contains(widget.headers[index]))
                      ? TextField(
                          controller: _controllers[index],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          ["STATES", "HOLD"].contains(widget.headers[index])
                              ? '---'
                              : widget.data[index],
                          style: Styles.textStyle14600.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
