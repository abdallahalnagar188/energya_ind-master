import 'package:flutter/material.dart';

class VerticalTable extends StatefulWidget {
  final List<String> headers;
  final List<String> data;
  final bool isEdit;

  const VerticalTable({
    super.key,
    required this.headers,
    required this.data,
    this.isEdit = false,
  });

  @override
  State<VerticalTable> createState() => VerticalTableState();
}

class VerticalTableState extends State<VerticalTable> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.data.isNotEmpty) {
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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.headers.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              // ✅ عرض الهيدر
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    widget.headers[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // ✅ عرض القيمة كـ Text أو TextField حسب وضع التعديل
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: (widget.isEdit == true &&
                              !["STATES", "HOLD"]
                                  .contains(widget.headers[index]))
                          ? 8
                          : 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: (widget.isEdit == true &&
                            !["STATES", "HOLD"].contains(widget.headers[index]))
                        ? Colors.grey.withValues(alpha: .3)
                        : null,
                  ),
                  child: (widget.isEdit == true &&
                          !["STATES", "HOLD"].contains(widget.headers[index]))
                      ? TextField(
                          controller: _controllers[index],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(widget.data[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
